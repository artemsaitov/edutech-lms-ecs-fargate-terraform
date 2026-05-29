terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# -----------------------------
# ECR Repository
# -----------------------------

resource "aws_ecr_repository" "lms_frontend" {
  name                 = "edutech-lms-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name    = "EduTech-LMS-Frontend-ECR"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# VPC
# -----------------------------

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "EduTech-VPC"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "EduTech-IGW"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# Availability Zones
# -----------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------
# Public Subnets
# -----------------------------

resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "EduTech-Public-Subnet-${count.index + 1}"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# Route Table
# -----------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "EduTech-Public-Route-Table"
    Project = "EduTech-LMS"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# -----------------------------
# Security Group for ALB
# -----------------------------

resource "aws_security_group" "alb" {
  name        = "EduTech-ALB-SG"
  description = "Allow HTTP traffic to the Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "EduTech-ALB-SG"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# Security Group for ECS Tasks
# -----------------------------

resource "aws_security_group" "ecs_tasks" {
  name        = "EduTech-Container-SG"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow ALB to reach container on port 3000"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "EduTech-Container-SG"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# IAM Role for ECS Task Execution
# -----------------------------

resource "aws_iam_role" "ecs_task_execution" {
  name = "EduTech-ECS-Task-Execution-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "EduTech-LMS"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------
# CloudWatch Log Group
# -----------------------------

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/edutech-lms-frontend"
  retention_in_days = 7

  tags = {
    Name    = "EduTech-LMS-Logs"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# ECS Cluster
# -----------------------------

resource "aws_ecs_cluster" "main" {
  name = "EduTech-LMS-Cluster"

  tags = {
    Name    = "EduTech-LMS-Cluster"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# Application Load Balancer
# -----------------------------

resource "aws_lb" "main" {
  name               = "EduTech-LMS-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name    = "EduTech-LMS-ALB"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# Target Group
# -----------------------------

resource "aws_lb_target_group" "main" {
  name        = "EduTech-LMS-TG"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name    = "EduTech-LMS-TG"
    Project = "EduTech-LMS"
  }
}

# -----------------------------
# ALB Listener
# -----------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# -----------------------------
# ECS Task Definition
# -----------------------------

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

# -----------------------------
# ECS Service
# -----------------------------

resource "aws_ecs_service" "lms" {
  name            = "EduTech-LMS-Service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.lms.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
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