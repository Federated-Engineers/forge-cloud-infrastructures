variable "team" {
  description = "The team responsible for the deployment"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g production, staging)"
  type        = string
}

variable "bucket-use-case" {
  description = "Use case of the bucket"
  type        = string
}

variable "service" {
  description = "The service using the bucket"
  type        = string
}

variable "versioning" {
  description = "versioning status for the S3 bucket (Enabled/Disabled)"
  type        = string
}