output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.prefect_api_key.arn
}

output "verification_instructions" {
  description = "Instructions to verify the work pool in Prefect Cloud"
  value       = <<EOT
1. Log in to Prefect Cloud at https://app.prefect.cloud.
2. Navigate to Work Pools and select 'ecs-work-pool'.
3. Check the status; it should show as 'Ready' if the worker is connected.
4. Optionally, deploy a sample flow to test the worker:
   - Create a flow in Prefect Cloud (e.g., a simple Python script).
   - Assign it to 'ecs-work-pool' and trigger a run.
   - Verify the flow runs successfully in the Prefect Cloud dashboard.
EOT
}
