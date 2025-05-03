# DevOps Internship 2025 Assignment Report

   ## Why Terraform?
   - Cross-cloud flexibility
   - Readable **HCL** syntax
   - Robust state management (better than **CloudFormation**)

   ---

   ## What I Learned
   - **Infrastructure as Code**: Mastered **Terraform** for provisioning **VPC**, **ECS**, **IAM**, **Secrets Manager**, and **CloudWatch**.
   - **AWS ECS**: Learned **Fargate**, service discovery, and networking.
   - **Prefect Cloud**: Understood free-tier limitations (`Prefect:managed` work pool only).
   - **Troubleshooting**: Resolved resource conflicts and **Terraform** errors.

   ---

   ## Challenges and Fixes
   ### 1. Prefect Free-Tier Limitation
   - **Problem**: Free tier supports only `Prefect:managed` work pool, not **ECS**.
   - **Fix**: Verified **ECS worker** functionality via **CloudWatch logs** (`/ecs/prefect-worker`) showing startup and API attempts.

   ### 2. Unable to Install Prefect
   - **Problem**: Could not install `prefect` Python package on **EC2**.
   - **Fix**: Skipped flow testing; used **AWS Console** and **CloudWatch logs** for verification.

   ### 3. Secrets Manager Conflict
   - **Problem**: `prefect-api-key-new` was scheduled for deletion.
   - **Fix**: Used `prefect-api-key-new-2`.

   ### 4. Existing Resources
   - **Problem**: **IAM role** (`prefect-task-execution-role`) and **CloudWatch log group** (`/ecs/prefect-worker`) already existed.
   - **Fix**: Deleted via **AWS Console**/**CLI**.

   ### 5. Terraform Errors
   - **Problem**: Deprecated `vpc` in `aws_eip`, incorrect **ECS cluster** reference.
   - **Fix**: Updated to `domain = "vpc"`, fixed `outputs.tf`.

   ### 6. Provider Mismatch
   - **Problem**: **AWS provider** version conflict.
   - **Fix**: Ran `terraform init -upgrade`.

   ---

   ## Demo
   Video at [https://drive.google.com/file/d/18MbG4JjDxoTz3XaJHgkW5GWz7pCGuI_i/view?usp=drive_link]

   ---

   ## Suggestions
   - **Auto-Scaling**: Add **ECS service** scaling based on CPU/memory.
   - **Monitoring**: Set up **CloudWatch** alarms for worker health.
   - **CI/CD**: Use **GitHub Actions** to automate deployment.
   - **Cost Optimization**: Use **Spot Instances** for workers.

   ---

   ## Conclusion
   Successfully deployed a **Prefect worker** on **ECS Fargate**, verified via **AWS Console** and **CloudWatch logs** due to free-tier limitations and inability to install `prefect`. This assignment improved my **IaC**, **AWS**, and problem-solving skills.
