resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = var.rsa_bits
}

resource "tls_cert_request" "this" {
  private_key_pem = tls_private_key.this.private_key_pem
  subject {
    common_name  = var.name
  }
}

resource "kubernetes_certificate_signing_request_v1" "this" {
  metadata {
    name = tls_cert_request.this.subject[0].common_name
  }
  spec {
    signer_name = "kubernetes.io/kube-apiserver-client"
    usages = var.usages
    request = tls_cert_request.this.cert_request_pem
  }
}

resource "kubernetes_cluster_role" "this" {
  provider = kubernetes
  count = length(var.cluster_role_rules) > 0 ? 1 : 0
  metadata {
    name = tls_cert_request.this.subject[0].common_name
  }
  dynamic "rule" {
    for_each = {for i, v in var.cluster_role_rules : i => v}
    content {
      api_groups = rule.value["api_groups"]
      resources = rule.value["resources"]
      verbs = rule.value["verbs"]
    }
  }
}

resource "kubernetes_cluster_role_binding" "this" {
  provider = kubernetes
  for_each = toset(concat(length(var.cluster_role_rules) > 0 ? [kubernetes_cluster_role.this[0].metadata[0].name] : [], var.cluster_role_bindings))
  metadata {
    name = tls_cert_request.this.subject[0].common_name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = each.value
  }
  subject {
    kind = "User"
    name = tls_cert_request.this.subject[0].common_name
  }
}