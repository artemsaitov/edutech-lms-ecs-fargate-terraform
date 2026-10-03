resource "aws_ecs_cluster" "main" {
  name = "EduTech-LMS-Cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name    = "EduTech-LMS-Cluster"
    Project = "EduTech-LMS"
  }
}


resource "aws_ecs_task_definition" "lms" {
  family                   = "EduTech-LMS-Task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "lms-frontend"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name    = "EduTech-LMS-Task"
    Project = "EduTech-LMS"
  }
}

resource "aws_ecs_service" "lms" {
  name            = "EduTech-LMS-Service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.lms.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  lifecycle {
  ignore_changes = [desired_count]
}

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_security_group_id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "lms-frontend"
    container_port   = 3000
  }

  tags = {
    Name    = "EduTech-LMS-Service"
    Project = "EduTech-LMS"
  }
}