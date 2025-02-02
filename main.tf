terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

provider "kubernetes" {
 config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "item-tracker-namespace" {
  metadata {
    name = "items-golang"
  }
}

resource "kubernetes_deployment" "item-tracker-deployment" {
  metadata {
    name = "item-tracker"
    namespace = kubernetes_namespace.item-tracker-namespace.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "item-tracker"
      }
    }
    template {
      metadata {
        labels = {
          app = "item-tracker"
        }
      }
      spec {
        container {
          image_pull_policy = "IfNotPresent"
          name  = "item-tracker"
          image = "item-tracker-go:4.0"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "item-tracker-service" {
    metadata {
      name = "item-tracker"
      namespace = kubernetes_namespace.item-tracker-namespace.metadata.0.name
    }
    spec {
      selector = {
        app = kubernetes_deployment.item-tracker-deployment.metadata.0.name
      }
      type = "NodePort"
      port {
        port = 8080
        target_port = 8080
      }
    }
}