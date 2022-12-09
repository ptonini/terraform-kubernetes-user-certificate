variable "name" {}

variable "usages" {
  default = ["client auth"]
}

variable "expiration_seconds" {
  default = 365 * 24 * 60 * 60
}

variable "rsa_bits" {
  default = 4096
}

variable "cluster_role_rules" {
  type = list(object({
    api_groups = list(string)
    resources  = list(string)
    verbs      = list(string)
  }))
  default = []
}

variable "cluster_role_bindings" {
  type    = list(string)
  default = []
}

variable "role_bindings" {
  type = list(object({
    name : string
    namespace : string
  }))
  default = []
}

variable "create_bindings" {
  default = true
}