locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}
    server: https://${google_container_cluster.primary.endpoint}:443
  name: ${local.cluster_name}
contexts:
- context:
    cluster: ${local.cluster_name}
    user: kubernetes-admin
  name: kubernetes-admin@${local.cluster_name}
current-context: kubernetes-admin@${local.cluster_name}
kind: Config
preferences: {}
users:
- name: kubernetes-admin
  user:
    client-certificate-data: ${google_container_cluster.primary.master_auth.0.client_certificate}
    client-key-data: ${google_container_cluster.primary.master_auth.0.client_key}
KUBECONFIG
}

output "kubeconfig" {
  value = local.kubeconfig
}
