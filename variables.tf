#-----------------------------------------
# Locals
#-----------------------------------------
locals {
  account_id = data.aws_caller_identity.current.account_id
}

locals {
  region = data.aws_region.current.name
}

locals {
  project     = "blog"
  env         = "dev"
  name_prefix = "${local.project}-${local.env}"
}

locals {
  domain = "example.com"
  fqdn   = "dev.${local.domain}"
}

locals {
  cf_logs_prefix = "access_log"
}

#-----------------------------------------
# Variables
#-----------------------------------------
variable "image_version" {
  type    = number
  default = 1
}

variable "email" {
  type    = string
  default = "hogehoge@example.com"
}

variable "microcms_content" {
  type    = string
  default = "hogehoge"
}

variable "blog_title" {
  type    = string
  default = "default blog title"
}

variable "profile_image_url" {
  type    = string
  default = "https://example.com"
}

variable "og_iamge_dir_url" {
  type    = string
  default = "https://example.com"
}

variable "blog_source_url" {
  type    = string
  default = "https://github.com/nkaxpta/BlogForNext.js.git"
}

variable "og_source_url" {
  type    = string
  default = "https://github.com/nkaxpta/Create-OpenGraphImage.git"
}
