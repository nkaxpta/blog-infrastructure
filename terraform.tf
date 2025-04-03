terraform {
  required_version = ">= 1.11.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.92.0"
    }
  }

  backend "s3" {
    bucket = "blog-dev-tfstate-bucket"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Managed_by = "terraform"
      Env        = local.env
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"

  default_tags {
    tags = {
      Managed_by = "terraform"
      Env        = local.env
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
