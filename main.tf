resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = var.rsa_bits
}

resource "tls_cert_request" "this" {
  private_key_pem = tls_private_key.this.private_key_pem
  subject {
    common_name = var.name
  }
}

resource "kubernetes_certificate_signing_request_v1" "this" {
  metadata {
    name = tls_cert_request.this.subject[0].common_name
  }
  spec {
    signer_name = "kubernetes.io/kube-apiserver-client"
    usages      = var.usages
    request     = tls_cert_request.this.cert_request_pem
  }
}

module "cluster_role" {
  source   = "ptonini/cluster-role/kubernetes"
  version  = "~> 1.1.0"
  for_each = var.cluster_roles
  name     = coalesce(each.value.name, each.key)
  rules    = each.value.rules
  subject = {
    kind = "User"
    name = kubernetes_certificate_signing_request_v1.this.metadata[0].name

  }
}

resource "kubernetes_cluster_role_binding_v1" "this" {
  for_each = toset(var.cluster_role_bindings)

  metadata {
    name = "${kubernetes_certificate_signing_request_v1.this.metadata[0].name}-${index(var.cluster_role_bindings, each.key)}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = each.value
  }

  subject {
    kind = "User"
    name = kubernetes_certificate_signing_request_v1.this.metadata[0].name
  }
}