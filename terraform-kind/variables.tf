variable "kubeconfig_path" {
  description = "Chemin du kubeconfig"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Contexte kubectl (cluster kind)"
  type        = string
  default     = "kind-juice"
}

variable "namespace" {
  type    = string
  default = "juice-shop"
}

variable "image" {
  type    = string
  default = "localhost/juice-shop:latest"
}

variable "replicas" {
  type    = number
  default = 1
}