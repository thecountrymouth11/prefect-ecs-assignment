DevOps Internship 2025 Assignment Report
Tool Choice
   Terraform: Chosen for its cross-cloud flexibility, readable HCL syntax, and robust state management. Preferred over CloudFormation for versatility.
Key Learnings

IaC: Mastered Terraform for provisioning VPC, ECS, IAM, Secrets Manager, and CloudWatch.
AWS ECS: Learned Fargate, service discovery, and networking.
Prefect: Understood free-tier limitations (Prefect:managed work pool only).
Troubleshooting: Resolved resource conflicts and Terraform errors.

Challenges and Resolutions

Prefect Free-Tier Limitation:
Problem: Free tier supports only Prefect:managed work pool, not ECS.
Solution: Verified ECS worker functionality via CloudWatch logs (/ecs/prefect-worker) showing startup and API attempts.


Unable to Install Prefect:
Problem: Could not install prefect Python package on EC2.
Solution: Skipped flow testing; relied on AWS Console and CloudWatch logs for verification.


Secrets Manager Conflict:
Problem: prefect-api-key-new was scheduled for deletion.
Solution: Used prefect-api-key-new-2.


Existing Resources:
Problem: IAM role (prefect-task-execution-role) and CloudWatch log group (/ecs/prefect-worker) already existed.
Solution: Deleted via AWS Console/CLI.


Terraform Errors:
Problem: Deprecated vpc in aws_eip, incorrect ECS cluster reference.
Solution: Updated to domain = "vpc", fixed outputs.tf.


Provider Mismatch:
Problem: AWS provider version conflict.
Solution: Ran terraform init -upgrade.



Demo
   Video at [to be added]
Suggestions for Improvement

Auto-Scaling: Add ECS service scaling based on CPU/memory.
Monitoring: Implement CloudWatch alarms for worker health.
CI/CD: Automate deployment with GitHub Actions.
Cost Optimization: Use Spot Instances for workers.

Conclusion
   Successfully deployed a Prefect worker on ECS Fargate, verified via AWS Console and CloudWatch logs due to free-tier limitations and inability to install prefect. This assignment enhanced my IaC, AWS, and problem-solving skills.

