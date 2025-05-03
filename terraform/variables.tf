variable "aws_region" {
     description = "AWS region"
     type        = string
     default     = "ap-south-1"
   }

   variable "prefect_api_key" {
     description = "Prefect Cloud API key"
     type        = string
     sensitive   = true
   }

   variable "prefect_api_url" {
     description = "Prefect Cloud API URL"
     type        = string
   }

   variable "prefect_account_id" {
     description = "Prefect Cloud account ID"
     type        = string
   }

   variable "prefect_workspace_id" {
     description = "Prefect Cloud workspace ID"
     type        = string
   }
