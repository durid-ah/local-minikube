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

resource "kubernetes_deployment" "kubernetes-bootcamp" {
  metadata {
    name = "minikube-bootcamp"
    namespace = kubernetes_namespace.item-tracker-namespace.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "minikube-bootcamp"
      }
    }
    template {
      metadata {
        labels = {
          app = "minikube-bootcamp"
        }
      }
      spec {
        container {
          name  = "minikube-bootcamp"
          image = "gcr.io/k8s-minikube/kubernetes-bootcamp:v1"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kubernetes-bootcamp" {
    metadata {
      name = "kubernetes-bootcamp"
      namespace = kubernetes_namespace.item-tracker-namespace.metadata.0.name
    }
    spec {
      selector = {
        app = kubernetes_deployment.kubernetes-bootcamp.metadata.0.name
      }
      type = "NodePort"
      port {
        port = 8080
        target_port = 8080
      }
    }
}