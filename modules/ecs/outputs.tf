output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.lms.name
}

output "service_id" {
  description = "ID of the ECS service"
  value       = aws_ecs_service.lms.id
}