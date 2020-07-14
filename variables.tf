variable "resourceGroupName" {
#   type        = "string"
  description = "The name of resource group"
  default     = "DemoAppServiceRG"
}

variable "location" {
#   type        = string
  description = "Location"
  default     = "eastus2"
}

variable "vnetName" {
# type        = string
description = "The name of virtual network"
default     = "DemoAppVnet"
}

variable "addressSpace" {
# type        = string
description = "Address Space for virtual network"
default     = ["10.1.0.0/16"]
}

variable "addressPrefix" {
# type        = string
description = "Address Prefix for subnet"
default     = "10.1.1.0/24"
}

variable "delSubnetName" {
# type        = string
description = "The name of delegated subnet"
default     = "acctestdelegation"
}

variable "plSubnetName" {
# type        = string
description = "The name of private link subnet"
default     = "plSubnet"
}

# var "plSubnetName"
# {
# type        = string
# description = "The name of private link subnet"
# default     = "xl"
# }

variable "plAddressPrefix" {
# type        = string
description = "Address Prefix for private link subnet"
default     = "10.1.2.0/24"
}

variable "appServicePlanName" {
#   type        = string
  description = "The name of app service plan"
  default     = "demolin-app-plan"
}

variable "appServiceName" {
#   type        = string
  description = "The name of app service"
  default     = "demo-simplejava-app"
}

variable "websiteDNSServer" {
#   type        = string
  description = "WEBSITE DNS SERVER"
  default     = "168.63.129.16"
}

variable "appMessage" {
#   type        = string
  description = "The App message"
  default     = "This is a demo app message"
}

variable "kvName" {
#   type        = string
  description = "The name of key vault"
  default     = "demo-kv-01"
}

variable "kvPEName" {
#   type        = string
  description = "The name of key vault private endpoint"
  default     = "kvpe"
}

variable "kvPSConn" {
#   type        = string
  description = "The name of key vault private service connection"
  default     = "kvpeconn"
}

variable "WebPEName" {
#   type        = string
  description = "The name of web private endpoint"
  default     = "webpe"
}

variable "WebPEConnName" {
#   type        = string
  description = "The name of web private endpoint"
  default     = "webpeconn"
}

variable "vaultcoreDNSName" {
#   type        = string
  description = "The DNS name of the Vault Core"
  default     = "privatelink.vaultcore.azure.net"
}

variable "websitesDNSName" {
#   type        = string
  description = "The DNS name of the web sites"
  default     = "privatelink.azurewebsites.net"
}

variable "appserviceDNSARecord" {
#   type        = string
  description = "The DNS A record of the app service"
  default     = ["10.1.2.4"]
}

variable "appserviceDNSSCM" {
#   type        = string
  description = "The DNS A record of the app service SCM"
  default     = "pr007lin-simplejava-app.scm"
}

variable "appVnetLinkDNSZone" {
#   type        = string
  description = "The DNS A record of the app service vnet link"
  default     = "webpe-link"
}

# variable "subscriptionId" {
#   type        = "string"
#   description = "Subscription id"
# }

# variable "tenantId" {
#   type        = "string"
#   description = "Tenant id"
# }

# variable "clientId" {
#   type        = "string"
#   description = "Client id"
# }

# variable "clientSecret" {
#   type        = "string"
#   description = "Client secret"
# }