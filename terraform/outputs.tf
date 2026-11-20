output "application_url" {
  description = "Local URL for the deployed application."
  value       = "http://127.0.0.1:${var.host_port}"
}

output "application_container" {
  description = "Name of the application container."
  value       = docker_container.app.name
}

output "gateway_container" {
  description = "Name of the gateway container."
  value       = docker_container.gateway.name
}

output "network_name" {
  description = "Docker network provisioned by Terraform."
  value       = docker_network.application.name
}
