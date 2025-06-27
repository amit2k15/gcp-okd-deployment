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

  tags = ["jenkins-server"]
}

resource "google_compute_firewall" "allow_jenkins" {
  name    = "allow-jenkins-traffic"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080", "6443", "8443", "3306", "30000-32767", "3000", "10051", "10050"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["jenkins-server"]
}
