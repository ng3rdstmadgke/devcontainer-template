# ■ デプロイ手順
## terraform の実行

### backend の設定

```bash
STAGE=prod  # 環境名を指定
cp $PROJECT_DIR/terraform/envs/${STAGE}/backend.sample.hcl $PROJECT_DIR/terraform/envs/${STAGE}/backend.hcl
```

`backend.sample.hcl` に tfstate 用の S3 バケット名を設定します。

`terraform/envs/${STAGE}/backend.hcl`

```hcl
bucket         = "tfstate-store-a5gnpkub"
```

### terraform コマンドの実行

```bash
cd $PROJECT_DIR/terraform

# terraform init の実行
make tf-init STAGE=prod

# terraform plan の実行
# terraform/.tfplan/STAGE/plan.tfgraph が生成されます。
make tf-plan STAGE=prod

# terraform apply の実行
make tf-apply STAGE=prod
```

## イメージのビルドと ECR へのプッシュ

```bash
STAGE=prod  # 環境名を指定
make push STAGE=$STAGE
```

## k8s のデプロイ方法

シークレットファイルを作成します。

```bash
STAGE=prod  # 環境名を指定
cp $PROJECT_DIR/k8s/overlays/$STAGE/secret.yaml.example $PROJECT_DIR/k8s/overlays/$STAGE/secret.yaml

# シークレットファイルの編集
vim $PROJECT_DIR/k8s/overlays/$STAGE/secret.yaml
```
シークレットファイルをデプロイします。

``bash
kubectl apply -f $PROJECT_DIR/k8s/overlays/$STAGE/secret.yaml
```

configmap を編集します。

```bash
# onfigMapGenerator の編集
vim $PROJECT_DIR/k8s/overlays/$STAGE/kustomization.yaml
```


デプロイを実行します。

```bash
kubectl apply -k $PROJECT_DIR/k8s/overlays/$STAGE
```


---



# ■ 削除手順

```bash
STAGE=prod  # 環境名を指定
kubectl delete -k $PROJECT_DIR/k8s/overlays/$STAGE
```

```bash
cd $PROJECT_DIR/terraform
make tf-destroy STAGE=prod
```