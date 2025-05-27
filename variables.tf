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

variable "ssh_pub_key_file" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "okd_version" {
  description = "OKD version to install"
  type        = string
  default     = "4.12.0"
}

variable "microservice1_repo" {
  description = "Git repository for microservice 1"
  type        = string
}

variable "microservice2_repo" {
  description = "Git repository for microservice 2"
  type        = string
}