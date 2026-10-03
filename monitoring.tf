resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/edutech-lms-frontend"
  retention_in_days = 7

  tags = {
    Name    = "EduTech-LMS-Logs"
    Project = "EduTech-LMS"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "edutech-lms-high-cpu"
  alarm_description   = "ECS service CPU utilization is above 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.service_name
  }

  treat_missing_data = "notBreaching"
}

resource "aws_cloudwatch_metric_alarm" "ecs_high_memory" {
  alarm_name          = "edutech-lms-high-memory"
  alarm_description   = "ECS service memory utilization is above 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.service_name
  }

  treat_missing_data = "notBreaching"
}