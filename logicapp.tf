resource "azurerm_resource_group_template_deployment" "logic_app_teams_api_connection" {
  name                = "logicapp-teams-api-conn-${var.env}"
  resource_group_name = azurerm_resource_group.rg.name
  template_content    = file("${abspath(path.module)}/schemas/logic-app-teams-api-connection.json")

  parameters_content = jsonencode({
    "connections_teams_name" = {
      value = "teams"
    }
    "location" = {
      value = azurerm_resource_group.rg.location
    }
    "subscriptionId" = {
      value = data.azurerm_subscription.current.id
    }
    "resourceGroupName" = {
      value = azurerm_resource_group.rg.name
    },
    "teamsLogin" = {
      value = var.teams_config.login
    }
  })

  deployment_mode = "Incremental"
}

resource "azurerm_logic_app_workflow" "logicapp" {
  name                = "logicapp-${var.env}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.tags

  workflow_parameters = {
    "$connections" = jsonencode(
      {
        defaultValue = {}
        type         = "Object"
      }
    )
  }

  parameters = {
    "$connections" = jsonencode(
      {
        teams = {
          connectionId   = "${data.azurerm_subscription.current.id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Web/connections/teams"
          connectionName = "teams"
          id             = "${data.azurerm_subscription.current.id}/providers/Microsoft.Web/locations/${azurerm_resource_group.rg.location}/managedApis/teams"
        }
      }
    )
  }

  depends_on = [azurerm_resource_group_template_deployment.logic_app_teams_api_connection]
}

resource "azurerm_logic_app_trigger_http_request" "logic_app_http_trigger" {
  name         = "logicapp-http-trigger-${var.env}"
  logic_app_id = azurerm_logic_app_workflow.logicapp.id

  schema = file("${abspath(path.module)}/schemas/http-trigger-schema.json")

}

resource "azurerm_logic_app_action_custom" "logic_app_init_variable" {
  name         = "init-variable"
  logic_app_id = azurerm_logic_app_workflow.logicapp.id

  body = file("${abspath(path.module)}/schemas/init-variable.json")
}

resource "azurerm_logic_app_action_custom" "logic_app_post_teams_channel" {
  name         = "post-teams-channel"
  logic_app_id = azurerm_logic_app_workflow.logicapp.id

  body = templatefile("${abspath(path.module)}/schemas/post-message-chat-or-channel-teams.json", {
    TEAMS_channelId = var.teams_config.channelId,
    TEAMS_groupId   = var.teams_config.groupId,
    INIT_VAR_ACTION = "init-variable"
  })

  depends_on = [azurerm_logic_app_action_custom.logic_app_init_variable]
}