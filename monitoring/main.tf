resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-rg"
  location = var.location
  tags     = local.tags
}

data "azurerm_subscription" "current" {
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.env}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "monitor-diagnostic-settings" {
  name                       = "send-to-law"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "Security"
    enabled  = true
  }
  log {
    category = "Alert"
    enabled  = true
  }

  lifecycle {
    ignore_changes = [log]
  }
}

resource "azurerm_monitor_aad_diagnostic_setting" "aad-diagnostic-settings" {
  name                       = "send-to-law"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  log {
    category = "SignInLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "AuditLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "NonInteractiveUserSignInLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "ServicePrincipalSignInLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "ManagedIdentitySignInLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "B2CRequestLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "ProvisioningLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "ADFSSignInLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "RiskyUsers"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "UserRiskEvents"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "NetworkAccessTrafficLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = false
    }
  }
  log {
    category = "RiskyServicePrincipals"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "ServicePrincipalRiskEvents"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
}