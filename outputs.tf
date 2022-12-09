output "this" {
  value = kubernetes_certificate_signing_request_v1.this
}

output "cluster_roles" {
  value = kubernetes_cluster_role.this
}

output "private_key" {
  value = tls_private_key.this
}