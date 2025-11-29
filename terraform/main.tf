// AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      PROJECT    = var.project_name
      STAGE      = var.stage
      managed_by = "terraform"
    }
  }
}

module "sample_app_ecr" {
  source           = "./modules/ecr"
  project_name     = var.project_name
  stage            = var.stage
  repository_name  = var.repository_name
}