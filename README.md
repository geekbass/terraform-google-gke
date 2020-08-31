# Running a GKE with Terraform >= .12  
Please refer to official [GKE Docs](https://cloud.google.com/kubernetes-engine/docs).

Please refer to specific [Terraform GKE](https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html) Docs.

This is a Regional Cluster setup with a new network.

Example:

```hcl
module "gke" {
 source                 = "geekbass/gke/google"
 version                = "~> 0.0.1"
 cluster_name           = "gke-cluster"
 region                 = "us-west-1"
 labels = {
   owner = "dave"
   type  = "kubernetes"
  }

 # Workers
 node_count                   = 6
 nodes_preemptible            = true

 providers = {
     google = google
 }
}
```
### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) 12 or later
- [GCLoud CLI](https://cloud.google.com/sdk/gcloud)

## Requirements

| Name | Version |
|------|---------|
| google | ~> 3.0 |
| kubernetes | ~> 1.11 |
| random | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.0 |
| kubernetes | ~> 1.11 |
| random | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | Name of the GKE Cluster. | `string` | `"my-gke-001"` | no |
| cluster\_name\_random\_string | Add a random string to the cluster name | `bool` | `false` | no |
| gke\_min\_master\_version | GKE Min Version to use. | `string` | `"latest"` | no |
| labels | Add custom tags to all resources | `map(string)` | `{}` | no |
| node\_count | Default Node Pool Count. | `number` | `2` | no |
| node\_extra\_count | Default Node Pool Count. | `number` | `0` | no |
| node\_extra\_pool\_machine\_type | Extra Node Pool Machine type. | `string` | `"n1-standard-4"` | no |
| node\_pool\_machine\_type | Default Node Pool Machine type. | `string` | `"n1-standard-4"` | no |
| nodes\_preemptible | Nodes to be preemptible. | `bool` | `true` | no |
| region | Google Region to use. | `string` | `"us-west2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| kubeconfig | n/a |

