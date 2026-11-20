resource "docker_network" "application" {
  name   = "cis4930-pipeline-network"
  driver = "bridge"
}

resource "docker_container" "app" {
  name    = "cis4930-app"
  image   = var.app_image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.application.name
  }
}

resource "docker_container" "gateway" {
  name    = "cis4930-gateway"
  image   = var.gateway_image_id
  restart = "unless-stopped"

  ports {
    internal = 80
    external = var.host_port
    ip       = "127.0.0.1"
  }

  networks_advanced {
    name = docker_network.application.name
  }

  depends_on = [docker_container.app]

  lifecycle {
    replace_triggered_by = [docker_container.app]
  }
}
