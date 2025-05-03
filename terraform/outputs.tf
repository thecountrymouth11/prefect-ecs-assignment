output "ecs_cluster_arn" {
       value       = aws_ecs_cluster.prefect.arn
       description = "ARN of the ECS cluster"
     }

     output "verification_instructions" {
       value = <<EOF
     To verify the Prefect worker:
     1. Log in to AWS Console (ap-south-1):
        - ECS > Clusters: Confirm 'prefect-cluster' exists.
        - ECS > Services: Verify 'dev-worker' is running (1 task, healthy).
        - CloudWatch > Log Groups: Check '/ecs/prefect-worker' for logs (worker startup, API connection).
        - Secrets Manager: Confirm 'prefect-api-key-new-2' contains the API key.
        - IAM > Roles: Verify 'prefect-task-execution-role' exists.
        - VPC: Confirm 'prefect-ecs' VPC with 6 subnets, NAT gateway, tags.
     2. Log in to Prefect Cloud (https://app.prefect.cloud):
        - Work Pools > Create > AWS ECS:
          - Name: ecs-work-pool
          - Cluster: prefect-cluster
          - Task Definition: prefect-worker
          - Subnets: Private subnets from VPC
          - Security Group: prefect_worker_sg
        - Note: ECS work pool requires a paid Prefect plan. If using free-tier, verify worker via CloudWatch logs.
     EOF
       description = "Instructions to verify the Prefect worker deployment"
     }
