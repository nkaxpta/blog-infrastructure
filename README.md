# Terraform

このリポジトリは下記ブログのインフラ構成を、TerraformでIaC化したものです。

https://mathenglog.net

## Architecture on AWS

![](./AWS_structure.drawio.svg)

## ディレクトリ構造

```
terraform/
├── acm.tf
├── apigateway.tf
├── cloudfront.tf
├── codebuild.tf
├── cwlogs_apigw.tf
├── cwlogs_cf.tf
├── cwlogs_codebuild.tf
├── cwlogs_lambda.tf
├── data.tf
├── docker
│   ├── Dockerfile
│   ├── README.md
│   ├── bootstrap
│   └── function.sh
├── ecr.tf
├── eventbridge.tf
├── iam_apigateway.tf
├── iam_codebuild.tf
├── iam_eventbridge.tf
├── iam_lambda.tf
├── lambda.tf
├── route53.tf
├── s3_blog.tf
├── s3_cf_log.tf
├── sns.tf
├── src
│   └── suffix_index.js
├── terraform.tf
└── variables.tf
```
## 使用方法

### 前提条件

- Terraform v1.0以上
- AWS CLI設定済み
- tfenvによるTerraformバージョン管理（推奨）
- Dockerがインストール済み (apply時にdocker bulid, push実行のため)

### variables.tfについて

variables.tf内にて定義されているlocalsやvariables（account_id, region以外）は各自の置き換えて利用してください。

- var.blog_source_url
  - 本ブログでは下記を指定しています。
  - https://github.com/nkaxpta/BlogForNext.js.git
  - ブログのフロント部分を作成しています。
- var.og_source_url
  - 上記ソースを基にする場合には下記を指定しておく必要があります。
  - https://github.com/nkaxpta/Create-OpenGraphImage.git
  - ここでブログ記事のサムネイルを自動作成しています。

### コマンド

```bash
# Initialization
terraform init

# Dry-run
terraform plan

# Deploy
terraform apply

# Destroy
terraform destroy
```