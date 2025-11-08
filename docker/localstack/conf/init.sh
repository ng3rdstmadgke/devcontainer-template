#!/bin/bash

# LocalStack - init-fooks: https://docs.localstack.cloud/references/init-hooks/
# デバッグコマンド: docker logs terraform-tutorial_devcontainer-localstack-1  | less
set -ex

export AWS_DEFAULT_REGION=ap-northeast-1

# secretsmanager: db secret
cat <<EOF > /tmp/mysql_secret.json
{
  "db_host": "sample-mysql",
  "db_password": "root1234",
  "db_port": "3306",
  "db_user": "root"
}
EOF
awslocal secretsmanager create-secret \
  --name "sample/local/mysql" \
  --secret-string file:///tmp/mysql_secret.json

cat <<EOF > /tmp/postgresql_secret.json
{
  "db_host": "sample-postgresql",
  "db_password": "root1234",
  "db_port": "5432",
  "db_user": "app"
}
EOF
awslocal secretsmanager create-secret \
  --name "sample/local/postgresql" \
  --secret-string file:///tmp/postgresql_secret.json

# sns
awslocal sns create-topic \
  --name sample-topic

# sqs: report job queue
awslocal sqs create-queue \
  --queue-name sample-sqs


# s3: app bucket
awslocal s3api create-bucket \
  --bucket sample \
  --create-bucket-configuration LocationConstraint=${AWS_DEFAULT_REGION}


# dynamodb: センサーデータテーブル
awslocal dynamodb create-table \
  --table-name SensorReadings \
  --attribute-definitions \
    AttributeName=pk,AttributeType=S \
    AttributeName=ts,AttributeType=S \
    AttributeName=sensorId,AttributeType=S \
    AttributeName=locationBucket,AttributeType=S \
  --key-schema \
    AttributeName=pk,KeyType=HASH \
    AttributeName=ts,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --global-secondary-indexes '[
    {
      "IndexName": "GSI_SensorLatest",
      "KeySchema": [
        {"AttributeName": "sensorId", "KeyType": "HASH"},
        {"AttributeName": "ts"      , "KeyType": "RANGE"}
      ],
      "Projection": {"ProjectionType": "ALL"}
    },
    {
      "IndexName": "GSI_LocationTime",
      "KeySchema": [
        {"AttributeName": "locationBucket", "KeyType": "HASH"},
        {"AttributeName": "ts"            , "KeyType": "RANGE"}
      ],
      "Projection": {"ProjectionType": "ALL"}
    }
  ]'

awslocal dynamodb update-time-to-live \
  --table-name SensorReadings \
  --time-to-live-specification "Enabled=true, AttributeName=expiresAt"


DAY=$(date -u +"%Y%m%d")
for i in {1..10}; do
  TS=$(date -u -d "${TS} +1 hour" +"%Y-%m-%dT%H:%M:%SZ")
  EXP=$(($(date -u +%s) + 90*24*3600))  # 90日保管
  for sensor_id in sensor-001 sensor-002 sensor-003; do
    temperature="$(shuf -i 20-30 -n 1).$(shuf -i 0-9 -n 1)"
    humidity="$(shuf -i 40-70 -n 1)"
    awslocal dynamodb put-item --table-name SensorReadings --item "{
      \"pk\": {\"S\": \"${sensor_id}#${DAY}\"},
      \"ts\": {\"S\": \"${TS}\"},
      \"sensorId\": {\"S\": \"${sensor_id}\"},
      \"locationBucket\": {\"S\": \"yokohama#${DAY}\"},
      \"temperature\": {\"N\": \"${temperature}\"},
      \"humidity\": {\"N\": \"${humidity}\"},
      \"expiresAt\": {\"N\": \"${EXP}\"}
    }"
  done
done