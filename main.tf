resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.env}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_monitor_action_group" "action_groups" {
  name                = "actiongroup-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "ag-cs"
  enabled             = true
  tags                = local.tags

  logic_app_receiver {
    name                    = "ms-teams-receiver"
    resource_id             = azurerm_logic_app_workflow.logicapp.id
    callback_url            = azurerm_logic_app_trigger_http_request.logic_app_http_trigger.callback_url
    use_common_alert_schema = true
  }
}