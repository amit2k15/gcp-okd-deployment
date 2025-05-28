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
  description = "SSH public key content (not file path)"
  type        = string
}

variable "okd_version" {
  description = "OKD version to install"
  type        = string
  default     = "4.17.0-okd-scos.0"
}
