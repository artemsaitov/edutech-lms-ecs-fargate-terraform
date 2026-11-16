variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the AWS role"
  type        = string
  default     = "artemsaitov/edutech-lms-ecs-fargate-terraform"
}