output "this" {
  value = kubernetes_certificate_signing_request_v1.this
}

output "private_key" {
  value = tls_private_key.this
}