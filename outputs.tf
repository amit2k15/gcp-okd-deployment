output "instance_public_ip" {
  description = "Public IP address of the VM instance"
  value       = google_compute_instance.zabbix74_vm.network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh ${var.ssh_user}@${google_compute_instance.zabbix74_vm.network_interface[0].access_config[0].nat_ip}"
}
