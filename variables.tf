variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "gcp_credentials" {
  description = "The GCP service account JSON key (as a string)"
  type        = string
  sensitive   = true
}

variable "gcp_region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-b"
}

variable "ssh_user" {
  description = "SSH user name"
  type        = string
  default     = "centos"
}

variable "ssh_pub_key" {
  description = "Public SSH key content"
  type        = string
}

variable "k8s_version" {
  description = "k8s version to install"
  type        = string
  default     = "4.17.0-k8s-scos.0"
}
