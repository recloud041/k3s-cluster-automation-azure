resource "azurerm_resource_group" "rg" {
    name     = var.resource_group_name
    location = var.location
    tags     = var.common_tags
}

resource "azurerm_proximity_placement_group" "ppg" {
    name                = var.ppg_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags                = var.common_tags
}

resource "azurerm_virtual_network" "vnet" {
    name                = var.vnet_name
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    tags                = var.common_tags
}

resource "azurerm_subnet" "subnet" {
    name                 = var.subnet_name
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
    subnet_id                 = azurerm_subnet.subnet.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_security_group" "nsg" {
    name                = var.nsg_name
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "ingress_rules" {
  for_each = {
    for rule in var.ingress_rules : rule.name => rule
  }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}


resource "azurerm_public_ip" "pip" {
    count               = var.vm_count
    name                = count.index == 0 ? "${var.vm_name_prefix}-master-pip" : "${var.vm_name_prefix}-worker-${count.index}-pip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
    count               = var.vm_count
    name                = count.index == 0 ? "${var.vm_name_prefix}-master-nic" : "${var.vm_name_prefix}-worker-${count.index}-nic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "internal"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.pip[count.index].id
    }
}

resource "azurerm_linux_virtual_machine" "vm" {
    count                 = var.vm_count
    name                  = count.index == 0 ? "${var.vm_name_prefix}-master" : "${var.vm_name_prefix}-worker-${count.index}"
    resource_group_name   = azurerm_resource_group.rg.name
    location              = azurerm_resource_group.rg.location
    size                  = "Standard_F4s_v2"
    admin_username        = "azureuser"
    tags                  = var.common_tags
    network_interface_ids = [azurerm_network_interface.nic[count.index].id]

    proximity_placement_group_id = azurerm_proximity_placement_group.ppg.id

    priority        = "Spot"
    eviction_policy = "Deallocate"

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb         = 30
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "ubuntu-24_04-lts"
        sku       = "server"
        version   = "latest"
    }

dynamic "admin_ssh_key" {
  for_each = var.ssh_public_keys
  content {
    username   = "azureuser"
    public_key = admin_ssh_key.value
  }
}

  custom_data = base64encode(<<EOF
#cloud-config
hostname: ${count.index == 0 ? "${var.vm_name_prefix}-master" : "${var.vm_name_prefix}-worker-${count.index}"}
fqdn: ${count.index == 0 ? "${var.vm_name_prefix}-master.local" : "${var.vm_name_prefix}-worker-${count.index}.local"}
EOF
  )

    disable_password_authentication = true
}

