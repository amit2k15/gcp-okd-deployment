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

resource "google_compute_instance" "k8s_vm" {
  name         = "k8s-vm"
  machine_type = "custom-2-4096"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-stream-9"
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
    ports    = ["80", "443", "6443", "8443", "3306", "30000-32767", "3000", "10051", "10050"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "mysql-service"]
}

output "vm_public_ip" {
  value = google_compute_instance.k8s_vm.network_interface[0].access_config[0].nat_ip
}
