##############################
## Azure App Service - Main ##
##############################

data "azurerm_client_config" "current" {}

# Create a resource group
resource "azurerm_resource_group" "app_pe_demo_rg" {
  name     = var.resourceGroupName
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "app_vnet" {
  name                = var.vnetName
  location            = azurerm_resource_group.app_pe_demo_rg.location
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
  address_space       = var.addressSpace
}

# Create an app subnet with delegation
resource "azurerm_subnet" "app_subnet" {
  name                 = "app_subnet"
  resource_group_name  = azurerm_resource_group.app_pe_demo_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefix       = var.addressPrefix

  delegation {
    name = var.delSubnetName

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Create an app subnet for private endpoint
resource "azurerm_subnet" "pl_subnet" {
  name                 = var.plSubnetName
  resource_group_name  = azurerm_resource_group.app_pe_demo_rg.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefix       = var.plAddressPrefix

  enforce_private_link_service_network_policies = true
  enforce_private_link_endpoint_network_policies = true

}

# Create an app service swift connection 
resource "azurerm_app_service_virtual_network_swift_connection" "app_swift_conn" {
  app_service_id = azurerm_app_service.demo_app_service.id
  subnet_id      = azurerm_subnet.app_subnet.id
}

# Create the Linux App Service Plan 
resource "azurerm_app_service_plan" "app_plan" {
  name                = var.appServicePlanName
  location            = azurerm_resource_group.app_pe_demo_rg.location
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "P1V2"
  }
}

# Create the App Service
resource "azurerm_app_service" "demo_app_service" {
  name                = var.appServiceName
  location            = azurerm_resource_group.app_pe_demo_rg.location
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  auth_settings {
    enabled = "true"
    runtime_version = "NODE|10-lts"
  }

 identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "WEBSITE_DNS_SERVER" = var.websiteDNSServer
    "WEBSITE_VNET_ROUTE_ALL"= "1"
    "APP_MESSAGE"= var.appMessage

  }
}

# Create a key vault
resource "azurerm_key_vault" "demo_kv" {
  name                        = var.kvName
  location                    = azurerm_resource_group.app_pe_demo_rg.location
  resource_group_name         = azurerm_resource_group.app_pe_demo_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get","set","delete"
    ]

    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "AppTesting"
  }
}

# Create a key vault secret
resource "azurerm_key_vault_secret" "demo_kv_secret" {
  name         = "APP-MESSAGE"
  value        = var.appMessage
  key_vault_id = azurerm_key_vault.demo_kv.id

  tags = {
    environment = "AppTesting"
  }
}

# Create a key vault access policy
resource "azurerm_key_vault_access_policy" "demo_kv_policy" {
  key_vault_id = azurerm_key_vault.demo_kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_app_service.demo_app_service.identity.0.principal_id

  secret_permissions = [
    "get","list"
  ]
}

# Create a private endpoint to the key vault
resource "azurerm_private_endpoint" "kvpe" {
  name                = var.kvPEName
  location            = azurerm_resource_group.app_pe_demo_rg.location
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
  subnet_id           = azurerm_subnet.pl_subnet.id

  private_service_connection {
    name                           = var.kvPSConn
    private_connection_resource_id = azurerm_key_vault.demo_kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

# Create a private endpoint to the app service
resource "azurerm_private_endpoint" "webpe" {
  name                = var.WebPEName
  location            = azurerm_resource_group.app_pe_demo_rg.location
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
  subnet_id           = azurerm_subnet.pl_subnet.id

  private_service_connection {
    name                           = var.WebPEConnName
    private_connection_resource_id = azurerm_app_service.demo_app_service.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}

# Create a DNS zone for the vault
resource "azurerm_private_dns_zone" "vaultcore" {
  name                = var.vaultcoreDNSName
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
}

# Create a DNS zone for the app service
resource "azurerm_private_dns_zone" "azurewebsites" {
  name                = var.websitesDNSName
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
}

# Create an A record for the app service
resource "azurerm_private_dns_a_record" "appservice" {
  name                = azurerm_app_service.demo_app_service.name
  zone_name           = azurerm_private_dns_zone.azurewebsites.name
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
  ttl                 = 300
  records             = var.appserviceDNSARecord
}

# Create an A record for the app service
resource "azurerm_private_dns_a_record" "scm" {
  name                = var.appserviceDNSSCM
  zone_name           = azurerm_private_dns_zone.azurewebsites.name
  resource_group_name = azurerm_resource_group.app_pe_demo_rg.name
  ttl                 = 300
  records             = var.appserviceDNSARecord
}

# Linking the private link vnet to the private DNS zone
resource "azurerm_private_dns_zone_virtual_network_link" "app_vnet_link" {
  name                  = var.appVnetLinkDNSZone
  resource_group_name   = azurerm_resource_group.app_pe_demo_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.azurewebsites.name
  virtual_network_id    = azurerm_virtual_network.app_vnet.id
}


