resource "azurerm_resource_group" "MessageQueueProcessorResourceGroup" {
  name        = var.ResourceGroupName
  location    = var.ResourceGroupLocation
}

resource "azurerm_storage_account" "MessageQueueProcessorStorageAccount" {
  name                       = var.StorageAccountName
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

resource "azurerm_application_insights" "MessageQueueProcessorAppInsights" {
  name                       = "MessageProcessorQueueAppInsights"
  resource_group_name        = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  location                   = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  application_type           = "web"
}

resource "azurerm_function_app" "MessageQueueProcessorFunctionApp" {
  name                       = var.FunctionAppName
  resource_group_name        = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  location                   = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  app_service_plan_id        = azurerm_app_service_plan.MessageQueueProcessorAppServicePlan.id
  storage_account_name       = azurerm_storage_account.MessageQueueProcessorStorageAccount.name
  storage_account_access_key = azurerm_storage_account.MessageQueueProcessorStorageAccount.primary_access_key
  version                    = "~4"
  site_config {
    use_32_bit_worker_process = false
    ftps_state                = "Disabled"
    linux_fx_version          = "DOTNET-ISOLATED|8.0"
  }
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE  = "1"
    AzureWebJobsStorage       = azurerm_storage_account.MessageQueueProcessorStorageAccount.primary_connection_string
    FUNCTIONS_WORKER_RUNTIME  = "dotnet-isolated"
    DOTNET_VERSION            = "8.0"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.MessageQueueProcessorAppInsights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.MessageQueueProcessorAppInsights.connection_string
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ManagedInstanceVnet"
  address_space       = ["10.40.0.0/24","10.41.0.0/24"]
  location            = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  resource_group_name = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
}

resource "azurerm_network_security_group" "nsg" {
  name                = "ManagedInstanceNSG"
  location            = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  resource_group_name = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  security_rule {
    name                       = "AllowInbound"
    description                = "Allow inbound traffic"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-healthprobe-in-10-0-1-0-24-v11"
    description                = "Allow Azure Load Balancer inbound traffic"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 101
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-internal-in-10-0-1-0-24-v11"
    description                = "Allow MI internal inbound traffic"
    direction                  = "Inbound"
    access                     = "Allow"
    priority                   = 102
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-aad-out-10-0-1-0-24-v11"
    description                = "Allow communication with Azure Active Directory over https"
    direction                  = "Outbound"
    access                     = "Allow"
    priority                   = 101
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-onedsc-out-10-0-1-0-24-v11"
    description                = "Allow communication with the One DS Collector over https"
    access                     = "Allow"
    direction                  = "Outbound"
    priority                   =  102
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-internal-out-10-0-1-0-24-v11"
    description                = "Allow MI internal outbound traffic"
    access                     = "Allow"
    direction                  = "Outbound"
    priority                   = 103
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-strg-p-out-10-0-1-0-24-v11"
    description                = "Allow outbound communication with storage over HTTPS"
    access                     = "Allow"
    direction                  = "Outbound"
    priority                   = 104
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-strg-s-out-10-0-1-0-24-v11"
    description                = "Allow outbound communication with storage over HTTPS"
    access                     = "Allow"
    direction                  = "Outbound"
    priority                   = 105
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Microsoft.Sql-managedInstances_UseOnly_mi-optional-azure-out-10-0-1-0-24"
    description                = "Allow AzureCloud outbound https traffic"
    access                     = "Allow"
    direction                  = "Outbound"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_route_table" "route_table" {
  name                = "ManagedInstanceRouteTable"
  location            = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  resource_group_name = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
}

resource "azurerm_subnet" "subnet" {
  name = "ManagedInstanceSubnet2"
  resource_group_name = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.40.0.0/24"]
  delegation {
    name = "sqlMI"
    service_delegation {
      name = "Microsoft.Sql/managedInstances"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "app_service_integration_subnet" {
  name = "AppServiceIntegrationSubnet2"
  resource_group_name = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.41.0.0/26"]
  delegation {
    name = "appServiceDelegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "devops_agent_subnet" {
  name = "DevOpsAgentSubnet"
  resource_group_name = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.41.0.64/27"]
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_route_table_association" "subnet_route_table_association" {
  subnet_id = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.route_table.id
}

data "azurerm_virtual_network" "core_net" {
  name                = "UKS-ELFH-CORENET-VNET"
  resource_group_name = "UKS-ELFH-CORENET-RG"
  subscription_id     = "68aa842d-b628-4755-9dc6-7f20d8c0cd10"
}

# Create peering from your ManagedInstanceVnet to CoreNet
resource "azurerm_virtual_network_peering" "sqlmi_to_corenet" {
  name                      = "SQLMI-to-CoreNet"
  resource_group_name       = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.core_net.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true 
}


resource "azurerm_mssql_managed_instance" "sqlmi" {
  name = var.SqlmiName
  resource_group_name = azurerm_resource_group.MessageQueueProcessorResourceGroup.name
  location = azurerm_resource_group.MessageQueueProcessorResourceGroup.location
  license_type = "BasePrice"
  administrator_login = var.SQLAdministratorLogin
  administrator_login_password = var.SQLAdministratorLoginPassword
  subnet_id = azurerm_subnet.subnet.id
  sku_name = var.SQLSkuName
  storage_size_in_gb = var.SQLStorageSize
  vcores = var.SQLVcores
  tags = {
    environment = var.Environment
  }
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    prevent_destroy = true
  }
  timeouts {
    create = "180m"
    update = "120m"
    delete = "60m"
  }
}

resource "azurerm_mssql_managed_database" "sqldb" {
  name = "GovNotifyMessage"
  managed_instance_id = azurerm_mssql_managed_instance.sqlmi.id
}
