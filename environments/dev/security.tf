resource "aws_security_group" "alb" {
  name        = "EduTech-ALB-SG"
  description = "Allow HTTP traffic to the Application Load Balancer"
  vpc_id      = module.network.vpc_id

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


resource "aws_security_group" "ecs_tasks" {
  name        = "EduTech-Container-SG"
  description = "Allow traffic from ALB to ECS tasks"
  vpc_id      = module.network.vpc_id

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
