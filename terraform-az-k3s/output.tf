output "vm_public_ips" {
  value = [for pip in azurerm_public_ip.pip : pip.ip_address]
  description = "Public IP addresses of the VMs"
} 
