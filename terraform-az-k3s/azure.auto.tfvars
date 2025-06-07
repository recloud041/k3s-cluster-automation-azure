ssh_public_keys = [
  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDL9Y8Gsj+luvuQytVs3KTSYDaXgaC+riVE0oX+3TfdpszoLi9Me7+tJnL/o+2rBKNaLXEZaBOmcexsXN9RIIfoDgHqbDXno7C5klkwfd+9msMQowwW1bhnoCT0zZlrtdLrrvq43u0yFE/qqYpDCTf+ykmELO07LFAIoAqtC1kjbezZJMuopm7QyKn74eImJZTV0SLEwH53tO1VXOwhkexM5hetF6wuGq7z0nOmAe8WJbxVMzwMLywCziXI/D1a3j8n/71jt0X0mEmBAzc/THU9WBB+3LT/HgjXzZi8SzsW5ilFpJaLE5WOqTnTLgs9eVpfUaSAuTv5TxZxc+c0GmnphklPIIF5OZ/1lDFU65evaV5OdSB6Zr7MpcL0a+s+I3J+6ZWzrxLB9g/+EtZpcEbQljDvNvQbX6Wd9FEBy5S51hzuIyOHANraBGxaXWTaEunqyQDY9DWtxI0f4zppbqzKWgmAlpLbkCq/qsHSbwGD/XrjiMbbXGqZQ1v+jezASPxRZLXebTdGmm3c7d26PNSzLFraYNfaARNmMRsMmlmq47o1pK1QBqDff1+UDmXaA8AM1Ho8JQ52X5xSXZSXubWhmuyLEOy9T3l7nGd9/UZ4Niak2bwEf4HaNzJgfgYMpuaZMwd+6QNqBJrRlP5J2tQ4LeThAlFKRb2zV42yOwDpCw==" #Azurek3slabkey
]

resource_group_name = "devops-internal-k3s-eastus"
location            = "East US"
ppg_name            = "ppg-k3s-cluster"
vm_count            = 3
subnet_name         = "k3s-subnet"
nsg_name            = "k3s-nsg"
vm_name_prefix      = "k3s-k3s"
vnet_name           = "k3s-vnet"
common_tags = {
  Environment = "dev"
  Client       = "TomCruise"
  Project     = "k3s-lab"
  CreatedBy   = "Terraform"
}

ingress_rules = [
  {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "k8s-apiserver"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "portainerd"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]