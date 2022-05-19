data "azurerm_subscription" "current" {
}

data "azurerm_log_analytics_workspace" "law" {
  name                = "${var.law-env}-law"
  resource_group_name = "${var.law-env}-rg"
}