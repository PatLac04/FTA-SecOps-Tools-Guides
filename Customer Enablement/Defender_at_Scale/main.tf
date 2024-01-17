## Current Management Group
data "azurerm_management_group" "example" {
  name = var.mgmt_group_name
}
resource "azurerm_resource_group" "security_rg" {
  name     = var.resource_group_name
  location = var.location
}

## Allows you to create LAW and onboard

resource "azurerm_log_analytics_workspace" "la_workspace" {
  name                = "mdc-security-workspace"
  location            = azurerm_resource_group.security_rg.location
  resource_group_name = azurerm_resource_group.security_rg.name
  sku                 = "PerGB2018"
}

## Policy Assignment

resource "azurerm_management_group_policy_assignment" "mcsb_assignment" {
  name                 = "mcsb"
  display_name         = "Microsoft Cloud Security Benchmark"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  management_group_id  = data.azurerm_management_group.example.id
}

# Enable Vuln Man
resource "azurerm_management_group_policy_assignment" "va_assignment" {
  name                 = "vuln-assess-servers"
  display_name         = "Vulnerbility Assessment for Machines"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/13ce0167-8ca6-4048-8e6b-f996402e3c1b"
  management_group_id  = data.azurerm_management_group.example.id
  location = var.location
  identity {
    type = "SystemAssigned"
  }
}

## Turning on Defender for Cloud

resource "azurerm_security_center_subscription_pricing" "mdc_arm" {
  tier          = "Standard"
  resource_type = "Arm"
  subplan       = "PerApiCall"
}

resource "azurerm_security_center_subscription_pricing" "mdc_servers" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"
  extension {
    name = "AgentlessVMScanning"
  }
  extension {
    name = "MdeDesignatedSubscription"
  }
}

resource "azurerm_security_center_subscription_pricing" "mdc_cspm" {
  tier          = "Standard"
  resource_type = "CloudPosture"
extension {
    name = "ContainerRegistriesVulnerabilityAssessments"
  }
 
  extension {
    name = "AgentlessVmScanning"
    additional_extension_properties = {
      ExclusionTags = "[]"
    }
  }
 
  extension {
    name = "AgentlessDiscoveryForKubernetes"
  }
 
  extension {
    name = "SensitiveDataDiscovery"
  }
}
resource "azurerm_security_center_subscription_pricing" "mdc_storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"
  subplan       = "DefenderForStorageV2"
}

resource "azurerm_security_center_subscription_pricing" "mdc_appservices" {
   tier = "Standard"
   resource_type = "AppServices"
}

resource "azurerm_security_center_subscription_pricing" "mdc_containerregistry" {
   tier = "Standard"
   resource_type = "ContainerRegistry"
}
 
resource "azurerm_security_center_subscription_pricing" "mdc_keyvaults" {
   tier = "Standard"
   resource_type = "KeyVaults"
}
 
resource "azurerm_security_center_subscription_pricing" "mdc_sqlservers" {
   tier = "Standard"
   resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "mdc_OpenSourceRelationalDatabases" {
  tier          = "Standard"
  resource_type = "OpenSourceRelationalDatabases"
}
resource "azurerm_security_center_subscription_pricing" "mdc_Containers" {
  tier          = "Standard"
  resource_type = "Containers"
}

# Security Contacts
resource "azurerm_security_center_contact" "mdc_contact" {
  email               = "john.doe@contoso.com"
  phone               = "+12380183043"
  alert_notifications = true
  alerts_to_admins    = true
}

