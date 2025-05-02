# Prefect Worker on Amazon ECS with Terraform

## Purpose
This project sets up a Prefect worker on AWS ECS to run tasks from Prefect Cloud, built using Terraform.

## Why Terraform
I chose Terraform because it’s easy to use and works with many clouds, not just AWS.

## How to Set Up
1. **What You Need**:
   - AWS account.
   - Terraform and AWS CLI installed.
   - Prefect Cloud account with API key and `ecs-work-pool`.
2. **Get the Code**:
   - Clone from GitHub: `git clone https://github.com/yourusername/prefect-ecs-assignment.git`
3. **Add Your Details**:
   - Edit `terraform/terraform.tfvars` with your Prefect details.
4. **Build**:
   ```bash
   cd terraform
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
