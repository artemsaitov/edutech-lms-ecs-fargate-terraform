resource "aws_ecs_cluster" "main" {
  name = "edutech-lms-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name    = "EduTech-LMS-${var.environment}-Cluster"
    Project = "EduTech-LMS"
  }
}

resource "aws_ecs_task_definition" "lms" {
  family                   = "edutech-lms-${var.environment}-task"
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

      healthCheck = {
        command = [
          "CMD-SHELL",
          "node -e \"require('http').get('http://127.0.0.1:3000/', r => process.exit(r.statusCode >= 200 && r.statusCode < 400 ? 0 : 1)).on('error', () => process.exit(1))\""
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

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
    Name    = "EduTech-LMS-${var.environment}-Task"
    Project = "EduTech-LMS"
  }
}

resource "aws_ecs_service" "lms" {
  name            = "edutech-lms-${var.environment}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.lms.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 60

  lifecycle {
  ignore_changes = [
    desired_count,
    task_definition
  ]
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
    Name    = "EduTech-LMS-${var.environment}-Service"
    Project = "EduTech-LMS"
  }
}