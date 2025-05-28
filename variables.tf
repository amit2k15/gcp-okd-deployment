variable "gcp_project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "ssh_user" {
  description = "SSH user name"
  type        = string
  default     = "centos"
}

variable "ssh_pub_key" {
  description = "Raw SSH public key content"
  type        = string
}
