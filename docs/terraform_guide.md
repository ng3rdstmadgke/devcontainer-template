# terraform の実行方法

このドキュメントでは、Terraform を使用してインフラストラクチャをコードとして管理する方法について説明します。

## backend の設定

```bash
STAGE=prod  # 環境名を指定
cp $PROJECT_DIR/terraform/envs/${STAGE}/backend.sample.hcl $PROJECT_DIR/terraform/envs/${STAGE}/backend.hcl
```

`backend.sample.hcl` に tfstate 用の S3 バケット名を設定します。

`terraform/envs/${STAGE}/backend.hcl`

```hcl
bucket         = "tfstate-store-a5gnpkub"
```

## terraform コマンドの実行

```bash
cd $PROJECT_DIR/terraform


# help の表示
make help

# terraform init の実行
make tf-init STAGE=prod

# terraform plan の実行
make tf-plan STAGE=prod

# terraform apply の実行
make tf-apply STAGE=prod

# terraform destroy の実行
make tf-destroy STAGE=prod

# terraform import の実行
make tf-import STAGE=prod TF_ADDR="aws_s3_bucket.my_bucket" RESOURCE_ID="my-bucket-name"

# tfstate のリスト表示
make tf-state-list STAGE=prod

# tfstate のロック解除
make tf-force-unlock STAGE=prod TF_LOCK_ID="xxxxxxxxxxxxxxxxxxxxxxxxxxx"

# tfstate のバックアップ取得
make tfstate-dump STAGE=prod
```