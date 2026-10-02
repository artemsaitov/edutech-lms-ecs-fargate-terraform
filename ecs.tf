resource "aws_ecs_cluster" "main" {
  name = "EduTech-LMS-Cluster"

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
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

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
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
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
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = "lms-frontend"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_iam_role_policy_attachment.ecs_task_execution
  ]

  tags = {
    Name    = "EduTech-LMS-Service"
    Project = "EduTech-LMS"
  }
}