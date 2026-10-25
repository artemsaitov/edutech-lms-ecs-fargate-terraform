resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/edutech-lms-prod"
  retention_in_days = 7

  tags = {
    Name    = "EduTech-LMS-prod-Logs"
    Project = "EduTech-LMS"
  }
}