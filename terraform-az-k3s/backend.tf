terraform {
  backend "azurerm" {
    resource_group_name  = "devops-team-rg-internal"
    storage_account_name = "terraformstatestore1234"      
    container_name       = "tfstate-k3s"
    key                  = "vms/k3s/dev/terraform.tfstate"
  }
}
