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
        container {
          image = "backend-app:latest"
          name  = "backend-container"

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name      = "backend-service"
    namespace = kubernetes_namespace.homelab.metadata[0].name
  }

  spec {
    selector = {
      app = "backend"
    }

    port {
      protocol    = "TCP"
      port        = 5000
      target_port = 5000
    }

    type = "ClusterIP"
  }
}