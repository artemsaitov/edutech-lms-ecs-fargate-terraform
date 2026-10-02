resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/edutech-lms-frontend"
  retention_in_days = 7

  tags = {
    Name    = "EduTech-LMS-Logs"
    Project = "EduTech-LMS"
  }
}
