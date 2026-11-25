output "namespace" {
  value = kubernetes_namespace.juice.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.juice.metadata[0].name
}