/** 
* # Running a GKE with Terraform >= .12
* Please refer to official [GKE Docs](https://cloud.google.com/kubernetes-engine/docs).
*
* 
* Please refer to specific [Terraform GKE](https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html) Docs.
* 
* This is a Regional Cluster setup with a new network.
* 
* Example:
*
* ```hcl
* module "gke" {
*  source                 = "geekbass/gke/google"
*  version                = "~> 0.0.1"
*  cluster_name           = "gke-cluster"
*  region                 = "us-west-1"
*  labels = {
*    owner = "dave"
*    type  = "kubernetes"
*   }
*
*  # Workers
*  node_count                   = 6
*  nodes_preemptible            = true
*
*  providers = {
*      google = google
*  }
* }
* ```
* ### Prerequisites
* - [Terraform](https://www.terraform.io/downloads.html) 12 or later
* - [GCLoud CLI](https://cloud.google.com/sdk/gcloud)
*/

provider "google" {
  version = "~> 3.0"
}

provider "random" {
  version = ">= 2.0"
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = var.cluster_name
}

locals {
  cluster_name = var.cluster_name_random_string ? random_id.id.hex : var.cluster_name
}

resource "google_container_cluster" "primary" {
  name                     = local.cluster_name
  location                 = var.region
  network                  = google_compute_network.gke.self_link
  subnetwork               = google_compute_subnetwork.gke.self_link
  remove_default_node_pool = var.node_count == 0 ? true : false
  initial_node_count       = var.node_count == 0 ? 1 : var.node_count

  min_master_version = var.gke_min_master_version

  ip_allocation_policy {
    cluster_secondary_range_name  = "cluster"
    services_secondary_range_name = "services"
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = true
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = timeadd(timestamp(), "24h")
      end_time   = timeadd(timestamp(), "36h")
      recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
    }
  }

  node_config {
    preemptible = var.nodes_preemptible
    # see https://cloud.google.com/compute/docs/machine-types
    machine_type = var.node_pool_machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = merge(
      var.labels,
      {
        "name"    = local.cluster_name,
        "cluster" = local.cluster_name,
      }
    )
  }

  resource_labels = merge(
    var.labels,
    {
      "name"    = local.cluster_name,
      "cluster" = local.cluster_name,
    }
  )
}

resource "google_container_node_pool" "extra_nodes" {
  name       = "${local.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_extra_count

  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_config {
    preemptible = var.nodes_preemptible
    # see https://cloud.google.com/compute/docs/machine-types
    machine_type = var.node_extra_pool_machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = merge(
      var.labels,
      {
        "name"    = local.cluster_name,
        "cluster" = local.cluster_name,
      }
    )
  }
}

resource "google_compute_network" "gke" {
  name                            = var.cluster_name
  auto_create_subnetworks         = false
  routing_mode                    = "GLOBAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "gke" {
  name          = var.cluster_name
  ip_cidr_range = "10.32.0.0/24"
  region        = var.region
  network       = google_compute_network.gke.id
  secondary_ip_range {
    range_name    = "cluster"
    ip_cidr_range = "10.0.0.0/16"
  }
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = "10.4.0.0/14"
  }
}

resource "google_compute_route" "internet-gateway" {
  name             = "${var.cluster_name}-internet-gateway"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.gke.name
  next_hop_gateway = "default-internet-gateway"
  priority         = 100
}

data "google_client_config" "current" {}

provider "kubernetes" {
  version                = "~> 1.11"
  load_config_file       = false
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

resource "kubernetes_cluster_role_binding" "gke-client-binding" {
  metadata {
    name = "gke-client-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind = "User"
    name = "client"
  }
}