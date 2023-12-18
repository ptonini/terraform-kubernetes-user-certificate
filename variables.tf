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

variable "cluster_roles" {
  type = map(object({
    name = optional(string)
    rules = list(object({
      api_groups        = list(string)
      resources         = list(string)
      verbs             = list(string)
      resource_names    = list(string)
      non_resource_urls = list(string)
    }))
  }))
  default  = {}
  nullable = false
}

variable "cluster_role_bindings" {
  type     = list(string)
  default  = []
  nullable = false
}