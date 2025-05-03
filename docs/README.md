Prefect Worker on AWS ECS Fargate
Purpose
   Deploys a Prefect worker on AWS ECS Fargate using Terraform, intended for a Prefect Cloud ECS work pool. Free-tier limits to Prefect:managed work pool, verified via CloudWatch logs.
IaC Tool

Tool: Terraform
Rationale: Flexible, readable HCL, robust state management.

Deployment Instructions

Prerequisites:
AWS account (sandbox), Terraform (>= 1.2.0), AWS CLI, Prefect Cloud account.
Configure AWS CLI: aws configure.
Set terraform.tfvars: aws_region, prefect_api_key, prefect_api_url, prefect_account_id, prefect_workspace_id.


Steps:cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan



Verification Steps

AWS Console (ap-south-1):
ECS > Clusters: Confirm prefect-cluster.
ECS > Services: Verify dev-worker running (1 task).
Secrets Manager: Check prefect-api-key-new-2.
IAM > Roles: Confirm prefect-task-execution-role.
VPC: Verify prefect-ecs VPC, 6 subnets, NAT gateway, tags (Name = prefect-ecs).
CloudWatch > Log Groups: Check /ecs/prefect-worker for worker logs (startup, API connection attempts).


Prefect Cloud (https://app.prefect.cloud):
Free-tier: Only Prefect:managed work pool supported.
Verification: ECS worker operational via CloudWatch logs due to ECS work pool limitation.
Paid plan: Create ECS work pool with prefect-cluster, prefect-worker, private subnets, prefect_worker_sg.



Cleanup
terraform destroy


Terminate EC2 instance in AWS Console.

Notes

Used prefect-api-key-new-2 due to Secrets Manager deletion conflict.
Deleted existing IAM role, CloudWatch log group (/ecs/prefect-worker) to resolve conflicts.
Skipped flow testing due to inability to install prefect on EC2; verified via AWS Console and logs.


