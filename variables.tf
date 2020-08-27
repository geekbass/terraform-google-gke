variable "region" {
  description = "Google Region to use."
  default     = "us-west2"
}

variable "cluster_name" {
  description = "Name of the GKE Cluster."
  default     = "my-gke-001"
}

variable "labels" {
  description = "Add custom tags to all resources"
  type        = map(string)
  default     = {}
}

variable "gke_min_master_version" {
  description = "GKE Min Version to use."
  default     = "latest"
}

variable "node_pool_machine_type" {
  description = "Default Node Pool Machine type."
  default     = "n1-standard-4"
}

variable "node_count" {
  description = "Default Node Pool Count."
  default     = 2
}

variable "node_extra_pool_machine_type" {
  description = "Extra Node Pool Machine type."
  default     = "n1-standard-4"
}

variable "node_extra_count" {
  description = "Default Node Pool Count."
  default     = 0
}

variable "nodes_preemptible" {
  description = "Nodes to be preemptible."
  default     = true
}

variable "cluster_name_random_string" {
  description = "Add a random string to the cluster name"
  default     = false
}
