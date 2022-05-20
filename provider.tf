locals {
  tags = {
    environment       = "poc"
    source-repository = "personal"
    created-by        = "terraform"
    Name              = "POC"
  }
}

provider "aws" {
  profile = "personalauroot"
  region  = var.aws_region

  default_tags {
    tags = local.tags
  }
}