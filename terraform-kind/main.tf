terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }
}

provider "kubernetes" {
  config_path    = pathexpand(var.kubeconfig_path)
  config_context = var.kube_context
}

resource "kubernetes_namespace" "juice" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment" "juice" {
  metadata {
    name      = "juice-shop"
    namespace = kubernetes_namespace.juice.metadata[0].name
    labels = {
      app = "juice-shop"
    }
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = {
        app = "juice-shop"
      }
    }

    template {
      metadata {
        labels = {
          app = "juice-shop"
        }
      }

      spec {
        container {
          name              = "juice-shop"
          image             = var.image
          image_pull_policy = "Never"

          port {
            container_port = 3000
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 20
            period_seconds        = 10
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 40
            period_seconds        = 20
          }

          security_context {
            run_as_non_root            = true
            run_as_user                = 65532
            allow_privilege_escalation = false
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "juice" {
  metadata {
    name      = "juice-shop"
    namespace = kubernetes_namespace.juice.metadata[0].name
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "juice-shop"
    }

    port {
      port        = 80
      target_port = 3000
    }
  }
}