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
}

resource "google_compute_instance" "okd_vm" {
  name         = "okd-vm"
  machine_type = "custom-4-8192" # 4 vCPUs, 8GB RAM
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-9"
      size  = 50 # 50 GB disk
      type  = "pd-ssd"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }

  metadata_startup_script = templatefile("${path.module}/scripts/install_okd.sh", {
    OKD_VERSION       = var.okd_version,
    MICROSERVICE1_REPO = var.microservice1_repo,
    MICROSERVICE2_REPO = var.microservice2_repo,
    PROJECT_ID        = var.gcp_project_id
  })

  tags = ["http-server", "mysql-service"]
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "6443", "8443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "mysql-service"]
}

output "vm_public_ip" {
  value = google_compute_instance.okd_vm.network_interface[0].access_config[0].nat_ip
}
