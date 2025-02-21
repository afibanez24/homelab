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
          image = "flask-app:latest"
          name  = "backend-container"
          image_pull_policy = "Never"  # 🚨 Evita que intente descargar la imagen de un registry externo

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}