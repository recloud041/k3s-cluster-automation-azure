resource "azurerm_monitor_action_group" "spot_vm_alert_group" {
    name                = "spot-vm-alert-group"
    resource_group_name = azurerm_resource_group.rg.name
    short_name          = "vm-alerts"
    
email_receiver {
    name          = "email"
    email_address = "manikantasatyasai758@gmail.com"
}
    tags = var.common_tags

}

resource "azurerm_monitor_activity_log_alert" "spot_vm_stopped_alert" {
  name                = "spot-vm-deallocate-alert"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "global"
  scopes              = [for vm in azurerm_linux_virtual_machine.vm : vm.id]
  description         = "Alert when a Spot VM is stopped or deallocated"
  enabled             = true

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/deallocate/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.spot_vm_alert_group.id
  }

  tags = var.common_tags
}

resource "azurerm_monitor_activity_log_alert" "spot_vm_poweroff_alert" {
  name                = "spot-vm-poweroff-alert"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "global"
  scopes              = [for vm in azurerm_linux_virtual_machine.vm : vm.id]
  description         = "Alert when a Spot VM is powered off"
  enabled             = true

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/powerOff/action"
  }

  action {
    action_group_id = azurerm_monitor_action_group.spot_vm_alert_group.id
  }

  tags = var.common_tags
}
