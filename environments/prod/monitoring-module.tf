module "monitoring" {
  source = "../../modules/monitoring"

  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name
}