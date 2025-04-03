locals {
  blog_repository_name = "${local.name_prefix}-file-move-s3"
}

#-----------------------------------------
# ECR
#-----------------------------------------
resource "aws_ecr_repository" "blog" {
  name                 = local.blog_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = local.blog_repository_name
  }
}

#-----------------------------------------
# Docker Build
#-----------------------------------------
resource "null_resource" "docker_build" {
  triggers = {
    version = var.image_version
  }
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${local.account_id}.dkr.ecr.${local.region}.amazonaws.com"
  }

  provisioner "local-exec" {
    command = "docker build -t ${local.blog_repository_name} docker/ --build-arg S3_SOURCE_BUCKET=${aws_s3_bucket.app.id} --build-arg CODEBUILD_PROJECT_NAME=${local.blog_project_name}"
  }

  provisioner "local-exec" {
    command = "docker tag ${local.blog_repository_name}:latest ${aws_ecr_repository.blog.repository_url}"
  }

  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.blog.repository_url}"
  }
}
