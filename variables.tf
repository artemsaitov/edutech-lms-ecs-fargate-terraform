variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "us-east-1"
}
variable "container_image" {
  description = "Full ECR image URI for the LMS frontend container"
  type        = string
}