variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "stage" {
  description = "The environment for the S3 bucket (e.g., dev, prod)."
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
}
