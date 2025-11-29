// AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      PROJECT    = "devcontainer-template",
      STAGE      = var.stage
      managed_by = "terraform"
    }
  }
}

module "sample_module" {
  source       = "./modules/sample_module"
  project_name = var.project_name
  bucket_name  = "example-bucket"
  stage        = var.stage
}