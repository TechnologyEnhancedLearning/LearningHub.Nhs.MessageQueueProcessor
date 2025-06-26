resource "azurerm_resource_group" "MessageQueueProcessorResourceGroup" {
  name        = var.ResourceGroupName
  location    = var.ResourceGroupLocation
}

resource "azurerm_storage_account" "MessageQueueProcessorStorageAccount" {
  name                       = "messagequeueprocessorsa"
  resource_group_name        = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  location                   = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  account_tier               = "Standard"
  account_replication_type   = "LRS"
}

resource "azurerm_app_service_plan" "MessageQueueProcessorAppServicePlan" {
  name                       = "MessageQueueProcessorAppServicePlan"
  resource_group_name        = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  location                   = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  kind                       = "FunctionApp"
  reserved                   = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "MessageQueueProcessorFunctionApp" {
  name                       = "MessageQueueProcessorApp"
  resource_group_name        = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  location                   = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  app_service_plan_id        = azurerm_app_service_plan.MessageQueueProcessorAppServicePlan.id
  storage_account_name       = azurerm_storage_account.MessageQueueProcessorStorageAccount.name
  storage_account_access_key = azurerm_storage_account.MessageQueueProcessorStorageAccount.primary_access_key
  version                    = "~4"
  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
    use_32_bit_worker_process = false
    always_on                 = true
    ftps_state                = "Disabled"
    scm_type                  = "None"
  }
  app_settings {
    WEBSITE_RUN_FROM_PACKAGE  = "~4"
    AzureWebJobsStorage       = "azurerm_storage_account.MessageQueueProcessorStorageAccount.primary_connection_string"
    FUNCTIONS_WORKER_RUNTIME  = "dotnet-isolated"
  }
}