terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  credentials = file("${path.module}/../gcp-key.json")
}

resource "google_compute_instance" "okd_vm" {
  name         = "okd-vm"
  machine_type = "custom-4-8192"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-9"
      size  = 50
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_pub_key}"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/install_okd.sh", {
    OKD_VERSION = "4.17.0-okd-scos.0"
    PROJECT_ID  = var.gcp_project_id
  })

  tags = ["http-server", "mysql-service"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "6443", "8443", "3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "mysql-service"]
}
