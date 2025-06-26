terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = ">=4.14.0"
    }
  }
  backend "azurerm" {
    resource_group_name     = "TerraformStorageRG"
    storage_account_name    = "userprofilesa11"
    container_name          = "tfstate"
    key                     = "MessageQueueProcessor.terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}