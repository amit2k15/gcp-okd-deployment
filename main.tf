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

resource "google_compute_instance" "jenkins_vm" {
  name         = "jenkins-vm"
  machine_type = "e2-medium"  # Recommended minimum for Jenkins
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"  # Common choice for Jenkins
      size  = 50  # GB (can be adjusted based on needs)
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

  # Uncomment and modify if you have a Jenkins installation script
  # metadata_startup_script = file("${path.module}/scripts/install_jenkins.sh")

  tags = ["jenkins-server", "http-server"]
}

resource "google_compute_firewall" "allow_jenkins_ports" {
  name    = "allow-jenkins-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8080", "50000", "80", "443"]  # Standard Jenkins ports + web ports
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins-server", "http-server"]
}

output "vm_public_ip" {
  value = google_compute_instance.jenkins_vm.network_interface[0].access_config[0].nat_ip
}
