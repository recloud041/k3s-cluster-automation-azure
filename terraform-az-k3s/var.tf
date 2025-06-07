variable "resource_group_name" {
  description = "The name of the resource group to create or use."
}

variable "location" {
  description = "The Azure region where resources will be deployed."
}

variable "ppg_name" {
  description = "The name of the proximity placement group."
}

variable "vm_count" {
  description = "The number of virtual machines to create."
}

variable "subnet_name" {
  description = "The name of the subnet to use."
}

variable "nsg_name" {
  description = "The name of the network security group."
}

variable "vm_name_prefix" {
  description = "The prefix for the virtual machine names."
}

variable "vnet_name" {
  description = "The name of the virtual network."
}

variable "ssh_public_keys" {
  type        = list(string)
  description = "List of SSH public keys to inject into the VM(s)."
}

variable "common_tags" {
  type        = map(string)
  description = "A map of common tags to apply to resources."
}

variable "ingress_rules" {
  description = "List of ingress NSG rules to apply"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}
