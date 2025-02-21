terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config" # Asegura que Kubernetes se pueda conectar
}

resource "kubernetes_namespace" "homelab" {
  metadata {
    name = "homelab"
  }
}

resource "kubernetes_deployment" "backend" {
  metadata {
    name      = "backend-deployment"
    namespace = kubernetes_namespace.homelab.metadata[0].name
    labels = {
      app = "backend"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        containers {  # 🚨 La clave correcta es "containers", no "container"
          container {
            name  = "backend-container"
            image = "flask-app:latest"
            image_pull_policy = "Never"  # Evita que intente descargar la imagen de un registry externo

            port {
              container_port = 5000
            }
          }
        }
      }
    }
  }
}