locals {
  og_project_cwlogs_name   = "/aws/codebuild/${local.og_project_name}"
  blog_project_cwlogs_name = "/aws/codebuild/${local.blog_project_name}"
}

#-----------------------------------------
# CloudWatch Logs
#-----------------------------------------
resource "aws_cloudwatch_log_group" "og_project_logs" {
  name              = local.og_project_cwlogs_name
  retention_in_days = 0

  tags = {
    Name = local.og_project_cwlogs_name
  }
}

resource "aws_cloudwatch_log_group" "blog_project_logs" {
  name              = local.blog_project_cwlogs_name
  retention_in_days = 0

  tags = {
    Name = local.blog_project_cwlogs_name
  }
}
