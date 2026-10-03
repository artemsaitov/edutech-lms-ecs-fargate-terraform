module "ecs" {
  source = "./modules/ecs"

  private_subnet_ids    = module.network.private_subnet_ids
  ecs_security_group_id = aws_security_group.ecs_tasks.id
  target_group_arn      = module.alb.target_group_arn
  execution_role_arn    = aws_iam_role.ecs_task_execution.arn
  log_group_name        = aws_cloudwatch_log_group.ecs.name
  container_image       = var.container_image
  aws_region            = var.aws_region
}