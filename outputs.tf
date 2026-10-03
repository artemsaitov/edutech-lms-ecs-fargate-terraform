output "ecr_repository_url" {
  value       = aws_ecr_repository.lms_frontend.repository_url
  description = "The URL of the ECR repository for the LMS frontend image."
}

output "application_url" {
  value       = "http://${module.alb.dns_name}"
  description = "The URL to access the LMS frontend application."
}

output "alb_dns_name" {
  value       = module.alb.dns_name
  description = "PublicDNS name of the Application Load Balancer."
}
output "ecs_cluster_name" {
  value       = aws_ecs_cluster.main.name
  description = "The name of the ECS cluster."
}

output "ecs_service_name" {
  value       = aws_ecs_service.lms.name
  description = "The name of the ECS service running the LMS frontend."
}

output "cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.ecs.name
  description = "The name of the CloudWatch Log Group for ECS logs."
}