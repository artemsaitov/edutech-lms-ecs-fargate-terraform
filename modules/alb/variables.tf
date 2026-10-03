variable "vpc_id" {
  description = "VPC where the ALB and target group are created"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the ALB"
  type        = string
}