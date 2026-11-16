resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/edutech-lms-dev"
  retention_in_days = 7

  tags = {
    Name    = "EduTech-LMS-dev-Logs"
    Project = "EduTech-LMS"
  }
}