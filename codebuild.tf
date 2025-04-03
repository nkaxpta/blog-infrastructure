locals {
  og_project_name   = "${local.name_prefix}-og-create-project"
  blog_project_name = "${local.name_prefix}-project"
}

#-----------------------------------------
# CodeBuild(Open Graph Create)
#-----------------------------------------
resource "aws_codebuild_project" "og_image_create" {
  name               = local.og_project_name
  description        = "Create OpenGraph images"
  project_visibility = "PRIVATE"
  source_version     = "main" # Git branch

  service_role = aws_iam_role.og_image.arn

  source {
    type            = "GITHUB"
    location        = var.og_source_url
    git_clone_depth = 1
  }

  environment {
    type         = "LINUX_LAMBDA_CONTAINER"
    compute_type = "BUILD_LAMBDA_2GB"
    image        = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"

    environment_variable {
      name  = "NEXT_PUBLIC_SERVICE_DOMAIN"
      type  = "PARAMETER_STORE"
      value = data.aws_ssm_parameter.microcms_api_key.name
    }

    environment_variable {
      name  = "NEXT_PUBLIC_API_KEY"
      type  = "PARAMETER_STORE"
      value = data.aws_ssm_parameter.microcms_api_domain.name
    }

    environment_variable {
      name  = "BLOG_DOMAIN"
      type  = "PLAINTEXT"
      value = local.domain
    }

    environment_variable {
      name  = "S3_SOURCE_BUCKET_NAME"
      type  = "PLAINTEXT"
      value = aws_s3_bucket.og.id
    }

    environment_variable {
      name  = "BLOG_TITLE"
      type  = "PLAINTEXT"
      value = var.blog_title
    }

    environment_variable {
      name  = "PROFILE_IMAGE_URL"
      type  = "PLAINTEXT"
      value = var.profile_image_url
    }
  }

  artifacts {
    type           = "S3"
    location       = aws_s3_bucket.og.id
    name           = local.og_project_name
    packaging      = "NONE"
    namespace_type = "NONE"
  }

  logs_config {
    cloudwatch_logs {
      group_name = local.og_project_cwlogs_name
      status     = "ENABLED"
    }
  }

  tags = {
    Name = local.og_project_name
  }
}


#-----------------------------------------
# CodeBuild(Blog Create)
#-----------------------------------------
resource "aws_codebuild_project" "blog_create" {
  name               = local.blog_project_name
  description        = "Create blog"
  project_visibility = "PRIVATE"
  source_version     = "main" # Git branch

  service_role = aws_iam_role.blog.arn

  source {
    type            = "GITHUB"
    location        = var.blog_source_url
    git_clone_depth = 1
  }

  environment {
    type         = "LINUX_LAMBDA_CONTAINER"
    compute_type = "BUILD_LAMBDA_2GB"
    image        = "aws/codebuild/amazonlinux-x86_64-lambda-standard:nodejs20"

    environment_variable {
      name  = "NEXT_PUBLIC_SERVICE_DOMAIN"
      type  = "PARAMETER_STORE"
      value = data.aws_ssm_parameter.microcms_api_key.name
    }

    environment_variable {
      name  = "NEXT_PUBLIC_API_KEY"
      type  = "PARAMETER_STORE"
      value = data.aws_ssm_parameter.microcms_api_domain.name
    }

    environment_variable {
      name  = "BLOG_DOMAIN"
      type  = "PLAINTEXT"
      value = local.domain
    }

    environment_variable {
      name  = "BLOG_TITLE"
      type  = "PLAINTEXT"
      value = var.blog_title
    }

    environment_variable {
      name  = "OG_IMAGE_DIR_URL"
      type  = "PLAINTEXT"
      value = var.blog_title
    }

    environment_variable {
      name  = "S3_SOURCE_BUCKET_NAME"
      type  = "PLAINTEXT"
      value = aws_s3_bucket.app.id
    }

    environment_variable {
      name  = "CLOUDFRONT_DISTRIBUTION_ID"
      type  = "PLAINTEXT"
      value = aws_cloudfront_distribution.blog.id
    }
  }

  artifacts {
    type           = "S3"
    location       = aws_s3_bucket.app.id
    name           = local.blog_project_name
    packaging      = "NONE"
    namespace_type = "NONE"
  }

  logs_config {
    cloudwatch_logs {
      group_name = local.blog_project_cwlogs_name
      status     = "ENABLED"
    }
  }

  tags = {
    Name = local.blog_project_name
  }
}
