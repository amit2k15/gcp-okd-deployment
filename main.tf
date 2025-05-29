terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project     = var.gcp_project_id
  region      = var.gcp_region
  credentials = var.gcp_credentials
}

resource "google_compute_instance" "okd_vm" {
  name         = "okd-vm"
  machine_type = "custom-8-16384"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "fedora-coreos-cloud/fedora-coreos-stable"
      size  = 100
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

  #metadata_startup_script = file("${path.module}/scripts/install_okd.sh")

  tags = ["http-server", "mysql-service"]
}

resource "google_compute_firewall" "allow_http_okd_new3" {
  name    = "allow-http-okd-new3"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "6443", "8443", "3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "mysql-service"]
}

output "vm_public_ip" {
  value = google_compute_instance.okd_vm.network_interface[0].access_config[0].nat_ip
}
