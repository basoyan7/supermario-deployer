terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws        = ">= 3.22.0"
    local      = ">= 1.4"
    random     = ">= 2.1"
    kubernetes = "~> 1.11"
    helm = ">= 1.0"
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>2.14.0"
    }
    docker-utils = {
      source  = "Kaginari/docker-utils"
      version = "0.0.4"
    }
  }
}
