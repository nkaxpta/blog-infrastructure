locals {
  lambda_policy_name = "${local.name_prefix}-lambda-policy"
  lambda_role_name   = "${local.name_prefix}-lambda-role"
}

#-----------------------------------------
# Assume Role
#-----------------------------------------
data "aws_iam_policy_document" "lambda_assumerole" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

#-----------------------------------------
# IAM Role
#-----------------------------------------
resource "aws_iam_role" "lambda_role" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assumerole.json

  tags = {
    Name = local.lambda_role_name
  }
}

resource "aws_iam_role_policy_attachment" "lambda_edit_s3" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_push_cwlogs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
