# EduTech LMS ECS Fargate Terraform Project

This project deploys a containerized Learning Management System frontend on AWS using ECS Fargate, ECR, an Application Load Balancer, CloudWatch Logs, IAM, VPC networking, Security Groups, and Terraform.

The goal of this project is to build a working cloud deployment first, then intentionally introduce and troubleshoot common ECS and ALB configuration issues.

## Services Used

- Amazon ECS with Fargate
- Amazon ECR
- Application Load Balancer
- Amazon CloudWatch Logs
- AWS IAM
- Amazon VPC
- Security Groups
- Terraform

## Project Plan

1. Build and push the LMS frontend Docker image to ECR.
2. Deploy AWS infrastructure using Terraform.
3. Confirm the application works through the ALB.
4. Intentionally create a configuration issue.
5. Troubleshoot using ECS service events, ALB target health, and CloudWatch logs.
6. Document the issue and resolution.