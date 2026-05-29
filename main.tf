# ECR Repository

resource "aws_ecr_repository" "lms_frontend" {
  name                 = "edutech-lms-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "EduTech-LMS-Frontend-ECR"
    Project = "EduTech-LMS"
  }
}