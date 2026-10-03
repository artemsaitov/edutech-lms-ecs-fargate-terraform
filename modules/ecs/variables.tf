variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM execution role ARN for ECS tasks"
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group for the application"
  type        = string
}

variable "container_image" {
  description = "Container image URI deployed by ECS"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}