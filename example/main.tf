provider "google" {
  version = "~> 3.0"
}

module "gke" {
  source       = "../"
  cluster_name = "gke-cluster-001"
  region       = "us-west1"
  labels = {
    owner      = "weston"
    expiration = "24h"
  }

  # Workers
  node_count        = 4
  nodes_preemptible = true

  providers = {
    google = google
  }
}

// Create admin.conf local file to be used for kubectl
resource "local_file" "kubeconfig" {
  content  = module.gke.kubeconfig
  filename = "${path.module}/kubeconfig.conf"
}

output "kubeconfig" {
  value = module.gke.kubeconfig
}
