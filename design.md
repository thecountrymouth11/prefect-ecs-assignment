# Design and Architecture for Prefect Worker on AWS ECS Fargate
## High-Level Design (HLD)
 The solution deploys a **Prefect worker** on **AWS ECS Fargate** using **Terraform** to execute workflows from **Prefect Cloud**. It provisions a secure, scalable infrastructure with networking, container orchestration, and secrets management, adhering to AWS best practices.

### Key Components
 - **VPC**: A custom VPC (`prefect-ecs`, CIDR `10.0.0.0/16`) isolates resources, with 3 public and 3 private subnets across multiple AZs for high availability.
 - **ECS Cluster**: `prefect-cluster` hosts the Fargate-based worker service.
 - **ECS Service**: `dev-worker` runs the Prefect worker container (`prefecthq/prefect:2-latest`) in private subnets.
 - **IAM Role**: `prefect-task-execution-role` grants permissions for ECS tasks to access **Secrets Manager** and execute Fargate tasks.
 - **Secrets Manager**: Stores the **Prefect API key** (`prefect-api-key-new-2`) securely.
 - **CloudWatch**: Logs worker activity at `/ecs/prefect-worker` for verification.
 - **NAT Gateway**: Enables private subnet outbound traffic (e.g., to Prefect Cloud).
 - **Prefect Cloud**: Manages workflows via a `Prefect:managed` work pool (free-tier limitation).

### Architecture Flow
 1. **Terraform** provisions the VPC, ECS cluster, IAM role, Secrets Manager, and networking.
 2. The **ECS service** (`dev-worker`) runs the Prefect worker container in **Fargate**, pulling the **Prefect API key** from **Secrets Manager**.
 3. The worker connects to **Prefect Cloud** via the NAT gateway to fetch tasks from the `Prefect:managed` work pool.
 4. **CloudWatch** captures worker logs for monitoring and verification.
 5. Users verify the setup via **AWS Console** and **Prefect Cloud**.

### Diagram
 ```
 [Prefect Cloud] <--> [NAT Gateway] <--> [Private Subnets: ECS Fargate Worker (dev-worker)]
     |                                      |
 [CloudWatch Logs]                   [Secrets Manager: API Key]
     |                                      |
 [AWS Console] <--> [VPC: prefect-ecs, ECS Cluster: prefect-cluster]
 ```

---

## Low-Level Design (LLD)
### VPC and Networking
 - **Resource**: `aws_vpc` (`prefect-ecs`, CIDR `10.0.0.0/16`).
 - **Subnets**:
   - 3 public subnets (`10.0.1.0/24`, `10.0.2.0/24`, `10.0.3.0/24`) in different AZs.
   - 3 private subnets (`10.0.4.0/24`, `10.0.5.0/24`, `10.0.6.0/24`) for ECS tasks.
 - **NAT Gateway**: Single NAT in a public subnet, attached to a route table for private subnets.
 - **Internet Gateway**: Enables public subnet outbound traffic.
 - **Tags**: `Name = prefect-ecs` on VPC, subnets, and NAT gateway.
 - **DNS**: Enabled via `enable_dns_hostnames`.

### ECS Cluster
 - **Resource**: `aws_ecs_cluster` (`prefect-cluster`).
 - **Service Discovery**: Private DNS namespace (`default.prefect.local`) for internal communication.

### ECS Service
 - **Resource**: `aws_ecs_service` (`dev-worker`).
 - **Launch Type**: Fargate.
 - **Container**: `prefecthq/prefect:2-latest`.
 - **Task Definition**:
   - CPU: 256, Memory: 512.
   - Environment variables: `PREFECT_API_URL`, `PREFECT_API_KEY` (from Secrets Manager), `PREFECT_WORK_POOL_NAME` (`ecs-work-pool`).
 - **Network**: Runs in private subnets, uses `prefect_worker_sg` security group (outbound to Prefect Cloud).

### IAM Role
 - **Resource**: `aws_iam_role` (`prefect-task-execution-role`).
 - **Policies**:
   - `AmazonECSTaskExecutionRolePolicy` (AWS-managed).
   - Custom policy for `secretsmanager:GetSecretValue` on `prefect-api-key-new-2`.
 - **Trust Policy**: Allows ECS tasks to assume the role.

### Secrets Manager
 - **Resource**: `aws_secretsmanager_secret` (`prefect-api-key-new-2`).
 - **Purpose**: Stores the Prefect API key securely, accessed by the ECS task.

### CloudWatch
 - **Resource**: `aws_cloudwatch_log_group` (`/ecs/prefect-worker`).
 - **Purpose**: Captures worker logs for debugging and verification.

---

## Code Architecture
### File Structure
 - `main.tf`: Defines VPC, subnets, NAT gateway, ECS cluster, service, IAM role, Secrets Manager, and CloudWatch log group.
 - `variables.tf`: Declares input variables (`aws_region`, `prefect_api_key`, `prefect_api_url`, `prefect_account_id`, `prefect_workspace_id`).
 - `outputs.tf`: Outputs the ECS cluster ARN.
 - `provider.tf`: Configures the AWS provider.
 - `terraform.tfvars`: Stores sensitive inputs (excluded from Git via `.gitignore`).
 - `.terraform.lock.hcl`: Locks provider versions.
 - `.gitignore`: Excludes sensitive files (`terraform.tfvars`, `terraform.tfstate`, `tfplan`).

### Key Components and Interactions
 - **VPC Module** (`main.tf`):
   - Creates `aws_vpc`, `aws_subnet`, `aws_internet_gateway`, `aws_nat_gateway`, `aws_route_table`.
   - Interacts with ECS service by providing private subnets.
 - **ECS Module** (`main.tf`):
   - Creates `aws_ecs_cluster`, `aws_ecs_service`, `aws_ecs_task_definition`.
   - Depends on VPC (subnets) and IAM role.
   - Pulls `prefect-api-key-new-2` from Secrets Manager.
 - **IAM Role** (`main.tf`):
   - Created via `aws_iam_role` and `aws_iam_role_policy`.
   - Attached to ECS task definition for Secrets Manager access.
 - **Secrets Manager** (`main.tf`):
   - Stores API key, referenced in task definition.
 - **Outputs** (`outputs.tf`):
   - Exports `ecs_cluster_arn` for verification.
 - **Variables** (`variables.tf`):
   - Parameterizes inputs for reusability.

### Flow
 1. `provider.tf` initializes the AWS provider.
 2. `variables.tf` and `terraform.tfvars` supply inputs (e.g., `prefect_api_key`).
 3. `main.tf` provisions resources in order: VPC → IAM → Secrets Manager → ECS → CloudWatch.
 4. `outputs.tf` displays the ECS cluster ARN.
 5. The ECS worker connects to Prefect Cloud, logs to CloudWatch.

---

## Challenges Addressed
 - **Free-Tier Limitation**: Used `Prefect:managed` work pool due to ECS work pool requiring a paid plan; verified via logs.
 - **Secrets Manager Conflict**: Used `prefect-api-key-new-2` to avoid deletion issues.
 - **Existing Resources**: Deleted conflicting IAM role and log group manually.
 - **Terraform Errors**: Fixed `domain = "vpc"` and provider version conflicts.

## Assumptions
 - Single NAT gateway used to reduce costs (free-tier compatible).
 - Free-tier Prefect Cloud account limits functionality.
 - No flow testing due to `prefect` installation failure on EC2.


