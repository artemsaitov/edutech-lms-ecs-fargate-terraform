resource "aws_ecr_repository" "lms_frontend" {
  name                 = "edutech-lms-frontend"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "EduTech-LMS-Frontend-ECR"
    Project = "EduTech-LMS"
  }
}

resource "aws_ecr_lifecycle_policy" "lms_frontend" {
  repository = aws_ecr_repository.lms_frontend.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the most recent 20 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}