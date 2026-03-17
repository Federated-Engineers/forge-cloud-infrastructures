variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-central-1"
}

variable "team" {
  description = "The team responsible for the deployment"
  type        = string
  default     = "forge"
}

variable "environment" {
  description = "The environment for the deployment"
  type        = string
  default     = "staging"
}

variable "bucket-use-case" {
  description = "Use case of the bucket (e.g. logs, data-lake, sftp)"
  type        = string
}

variable "service" {
  description = "The service using the bucket (e.g. airflow, lambda, glue, sagemaker, ec2, etc.)"
  type        = string
}

variable "versioning" {
  description = "versioning status for the S3 bucket (Enabled/Disabled)"
  type        = string
  default     = "Disabled"
}


