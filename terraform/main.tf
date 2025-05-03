# Defining the VPC
     resource "aws_vpc" "main" {
       cidr_block           = "10.0.0.0/16"
       enable_dns_hostnames = true
       enable_dns_support   = true
       tags = {
         Name = "prefect-ecs"
       }
     }

     # Defining the subnets
     resource "aws_subnet" "public" {
       count                   = 3
       vpc_id                  = aws_vpc.main.id
       cidr_block              = "10.0.${count.index + 1}.0/24"
       availability_zone       = element(data.aws_availability_zones.available.names, count.index)
       map_public_ip_on_launch = true
       tags = {
         Name = "prefect-public-${count.index + 1}"
       }
     }

     resource "aws_subnet" "private" {
       count             = 3
       vpc_id            = aws_vpc.main.id
       cidr_block        = "10.0.${count.index + 4}.0/24"
       availability_zone = element(data.aws_availability_zones.available.names, count.index)
       tags = {
         Name = "prefect-private-${count.index + 1}"
       }
     }

     # Defining the internet gateway
     resource "aws_internet_gateway" "main" {
       vpc_id = aws_vpc.main.id
       tags = {
         Name = "prefect-ecs"
       }
     }

     # Defining the route table
     resource "aws_route_table" "public" {
       vpc_id = aws_vpc.main.id
       route {
         cidr_block = "0.0.0.0/0"
         gateway_id = aws_internet_gateway.main.id
       }
       tags = {
         Name = "prefect-public"
       }
     }

     resource "aws_route_table_association" "public" {
       count          = 3
       subnet_id      = aws_subnet.public[count.index].id
       route_table_id = aws_route_table.public.id
     }

     # Defining the NAT gateway
     resource "aws_eip" "nat" {
       domain = "vpc"
       tags = {
         Name = "prefect-nat"
       }
     }

     resource "aws_nat_gateway" "main" {
       allocation_id = aws_eip.nat.id
       subnet_id     = aws_subnet.public[0].id
       tags = {
         Name = "prefect-nat"
       }
     }

     resource "aws_route_table" "private" {
       vpc_id = aws_vpc.main.id
       route {
         cidr_block     = "0.0.0.0/0"
         nat_gateway_id = aws_nat_gateway.main.id
       }
       tags = {
         Name = "prefect-private"
       }
     }

     resource "aws_route_table_association" "private" {
       count          = 3
       subnet_id      = aws_subnet.private[count.index].id
       route_table_id = aws_route_table.private.id
     }

     # Defining the security group
     resource "aws_security_group" "prefect_worker" {
       vpc_id = aws_vpc.main.id
       egress {
         from_port   = 0
         to_port     = 0
         protocol    = "-1"
         cidr_blocks = ["0.0.0.0/0"]
       }
       tags = {
         Name = "prefect-worker-sg"
       }
     }

     # Defining the ECS cluster
     resource "aws_ecs_cluster" "prefect" {
       name = "prefect-cluster"
       tags = {
         Name = "prefect-ecs"
       }
     }

     # Defining the IAM role
     resource "aws_iam_role" "prefect_task_execution_role" {
       name = "prefect-task-execution-role"
       assume_role_policy = jsonencode({
         Version = "2012-10-17"
         Statement = [
           {
             Action = "sts:AssumeRole"
             Effect = "Allow"
             Principal = {
               Service = "ecs-tasks.amazonaws.com"
             }
           }
         ]
       })
       tags = {
         Name = "prefect-ecs"
       }
     }

     resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
       role       = aws_iam_role.prefect_task_execution_role.name
       policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
     }

     resource "aws_iam_role_policy" "secrets_access" {
       name = "SecretsAccessPolicy"
       role = aws_iam_role.prefect_task_execution_role.id
       policy = jsonencode({
         Version = "2012-10-17"
         Statement = [
           {
             Effect = "Allow"
             Action = [
               "secretsmanager:GetSecretValue",
               "secretsmanager:DescribeSecret"
             ]
             Resource = [aws_secretsmanager_secret.prefect_api_key.arn]
           }
         ]
       })
     }

     # Defining the Secrets Manager secret
     resource "aws_secretsmanager_secret" "prefect_api_key" {
       name = "prefect-api-key-new-2"
     }

     resource "aws_secretsmanager_secret_version" "prefect_api_key_version" {
       secret_id     = aws_secretsmanager_secret.prefect_api_key.id
       secret_string = var.prefect_api_key
     }

     # Defining the CloudWatch log group
     resource "aws_cloudwatch_log_group" "prefect" {
       name              = "/ecs/prefect-worker"
       retention_in_days = 7
       tags = {
         Name = "prefect-ecs"
       }
     }

     # Defining the ECS task definition
     resource "aws_ecs_task_definition" "prefect_worker" {
       family                   = "prefect-worker"
       network_mode             = "awsvpc"
       requires_compatibilities = ["FARGATE"]
       cpu                      = "256"
       memory                   = "512"
       execution_role_arn       = aws_iam_role.prefect_task_execution_role.arn
       container_definitions = jsonencode([
         {
           name  = "prefect-worker"
           image = "prefecthq/prefect:2-latest"
           essential = true
           command = [
             "prefect", "worker", "start",
             "--pool", "ecs-work-pool",
             "--type", "ecs"
           ]
           environment = [
             {
               name  = "PREFECT_API_URL"
               value = var.prefect_api_url
             },
             {
               name  = "PREFECT_CLOUD_WORKSPACE_ID"
               value = var.prefect_workspace_id
             }
           ]
           secrets = [
             {
               name      = "PREFECT_API_KEY"
               valueFrom = aws_secretsmanager_secret.prefect_api_key.arn
             }
           ]
           logConfiguration = {
             logDriver = "awslogs"
             options = {
               awslogs-group         = aws_cloudwatch_log_group.prefect.name
               awslogs-region        = var.aws_region
               awslogs-stream-prefix = "prefect"
             }
           }
         }
       ])
       tags = {
         Name = "prefect-ecs"
       }
     }

     # Defining the ECS service
     resource "aws_ecs_service" "prefect_worker" {
       name            = "dev-worker"
       cluster         = aws_ecs_cluster.prefect.id
       task_definition = aws_ecs_task_definition.prefect_worker.arn
       desired_count   = 1
       launch_type     = "FARGATE"
       network_configuration {
         subnets          = aws_subnet.private[*].id
         security_groups  = [aws_security_group.prefect_worker.id]
         assign_public_ip = false
       }
       service_registries {
         registry_arn = aws_service_discovery_service.prefect.arn
       }
       tags = {
         Name = "prefect-ecs"
       }
     }

     # Defining the service discovery
     resource "aws_service_discovery_private_dns_namespace" "prefect" {
       name        = "prefect.local"
       vpc         = aws_vpc.main.id
       description = "Private DNS namespace for Prefect ECS"
     }

     resource "aws_service_discovery_service" "prefect" {
       name = "default"
       dns_config {
         namespace_id = aws_service_discovery_private_dns_namespace.prefect.id
         dns_records {
           ttl  = 10
           type = "A"
         }
       }
       health_check_custom_config {
         failure_threshold = 1
       }
     }
