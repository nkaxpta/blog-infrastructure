data "aws_ssm_parameter" "microcms_api_domain" {
  name            = "/${local.project}/prd/codebuild/microcms/api/domain"
  with_decryption = true
}

data "aws_ssm_parameter" "microcms_api_key" {
  name            = "/${local.project}/prd/codebuild/microcms/api/key"
  with_decryption = true
}
