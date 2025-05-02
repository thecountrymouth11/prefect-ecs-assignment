variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "prefect_api_key" {
  description = "Prefect Cloud API key"
  type        = string
  sensitive   = true
}

variable "prefect_account_id" {
  description = "Prefect Cloud Account ID"
  type        = string
}

variable "prefect_workspace_id" {
  description = "Prefect Cloud Workspace ID"
  type        = string
}

variable "prefect_account_url" {
  description = "Prefect Cloud Account URL"
  type        = string
}
