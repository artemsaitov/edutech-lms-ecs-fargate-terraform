output "ecr_repository_url" {
  value       = aws_ecr_repository.lms_frontend.repository_url
  description = "The URL of the ECR repository for the LMS frontend image."
}