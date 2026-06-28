output "alb_dns" {
  value = module.alb.dns_name
}

output "cluster_id" {
  value = module.ecs.cluster_id
}

output "service_name" {
  value = module.ecs.services["web"].name
}

