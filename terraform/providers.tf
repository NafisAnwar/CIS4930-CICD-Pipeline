terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.7.0"
    }
  }

  backend "local" {}
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}
