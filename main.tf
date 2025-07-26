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

resource "google_compute_instance" "zabbix7.4_vm" {
  name         = "zabbix7.4-vm"
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

  tags = ["http-server", "zabbix7.4-server"]
}

resource "google_compute_firewall" "allow-zabbix7.4" {
  name    = "allow-zabbix7.4"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080", "50000", "3306"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "zabbix7.4-server"]
}

output "vm_public_ip" {
  value = google_compute_instance.zabbix7.4_vm.network_interface[0].access_config[0].nat_ip
}
