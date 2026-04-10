output "vm_id" {
  description = "Proxmox VM ID of the created virtual machine"
  value       = proxmox_virtual_environment_vm.vm.vm_id
}

output "vm_ip" {
  description = "Primary IP address of the VM (from cloud-init or DHCP)"
  value       = try(proxmox_virtual_environment_vm.vm.ipv4_addresses[1][0], "pending")
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "vm_status" {
  description = "Current status of the VM (running, stopped, etc.)"
  value       = proxmox_virtual_environment_vm.vm.started ? "running" : "stopped"
}
