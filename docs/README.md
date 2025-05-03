# Prefect Worker on Amazon ECS with Terraform

   ## Purpose
   This project sets up a **Prefect worker** on **AWS ECS Fargate** using **Terraform** to execute tasks from **Prefect Cloud**. Due to AWS Free Tier limitations, only a `Prefect:managed` work pool is supported. ECS worker functionality is verified via **CloudWatch logs**.

   ---

   ## Why Terraform?
   - Flexible, readable HCL syntax
   - Cross-cloud support
   - Robust state management (easier than **CloudFormation**)

   ---

   ## Prerequisites
   You will need:
   - An **AWS account** (sandbox recommended)
   - [**Terraform**](https://www.terraform.io/downloads) version >= 1.2.0
   - [**AWS CLI**](https://aws.amazon.com/cli/) installed and configured
   - A [**Prefect Cloud**](https://www.prefect.io/cloud/) account with:
     - API Key
     - A `Prefect:managed` work pool  
       *(Note: ECS work pools require a paid Prefect plan)*

   ---

   ## Setup Instructions
   ### 1. Clone the Repository
   ```bash
   git clone https://github.com/yourusername/prefect-ecs-assignment.git
   cd prefect-ecs-assignment/terraform
   ```

   ### 2. Configure AWS CLI
   ```bash
   aws configure
   ```

   ### 3. Add Prefect Details
   - Edit `terraform.tfvars` with:
     - `aws_region`
     - `prefect_api_key`
     - `prefect_api_url`
     - `prefect_account_id`
     - `prefect_workspace_id`

   ### 4. Deploy the Infrastructure
   ```bash
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

   ### 5. Verify the Deployment
   - **AWS Console (ap-south-1)**:
     - **ECS** > **Clusters**: Confirm `prefect-cluster` exists.
     - **ECS** > **Services**: Verify `dev-worker` is running (1 task, healthy).
     - **Secrets Manager**: Check `prefect-api-key-new-2` contains the correct **API key**.
     - **IAM** > **Roles**: Confirm `prefect-task-execution-role` with attached policies.
     - **VPC**: Verify `prefect-ecs` VPC with 6 subnets (3 public, 3 private), NAT gateway, and tags (`Name = prefect-ecs`).
     - **CloudWatch** > **Log Groups**: Check `/ecs/prefect-worker` for worker logs (e.g., startup, API connection attempts).
   - **Prefect Cloud**:
     - Visit [**Prefect Cloud**](https://app.prefect.cloud).
     - Confirm `Prefect:managed` work pool exists (ECS work pool not supported in free tier
