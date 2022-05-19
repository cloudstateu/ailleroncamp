resource "azurerm_monitor_scheduled_query_rules_alert" "security_activity_log_alert" {
  name                = "${var.env}-security-activity-log"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  action {
    action_group = [azurerm_monitor_action_group.action_group.id]
  }

  data_source_id = data.azurerm_log_analytics_workspace.law.id
  description    = "Security activity log alert"
  enabled        = true
  query          = <<-QUERY
    AzureActivity
    | where CategoryValue == "Security" 
        and Level in ("Critical", "Error")
    QUERY

  severity    = 1
  frequency   = 60
  time_window = 60
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  tags = local.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert" "azuread_activity_log_alert" {
  name                = "${var.env}-azuread-alert-activity-log"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  action {
    action_group = [azurerm_monitor_action_group.action_group.id]
  }

  data_source_id = data.azurerm_log_analytics_workspace.law.id
  description    = "Users did not pass the MFA challenge"
  enabled        = true
  query          = <<-QUERY
    SigninLogs
    | where ResultType == "50074"
    | summarize FailedSigninCount = count(), max(ResultType) by UserDisplayName
    | sort by FailedSigninCount desc
    | order by FailedSigninCount desc
    QUERY

  severity    = 3
  frequency   = 60
  time_window = 60
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  tags = local.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert" "azuread_spn_expired_alert" {
  name                = "${var.env}-azuread-spn-expired-log"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  action {
    action_group = [azurerm_monitor_action_group.action_group.id]
  }

  data_source_id = data.azurerm_log_analytics_workspace.law.id
  description    = "Azure AD service principals that have both successful and failed sign ins because of an expired secret"
  enabled        = true
  query          = <<-QUERY
    AADServicePrincipalSignInLogs
    | where TimeGenerated > ago(1d)
    | summarize
        ['All Error Codes']=make_set(ResultType),
        ['Successful IP Addresses']=make_set_if(IPAddress, ResultType == 0),
        ['Failed IP Addresses']=make_set_if(IPAddress, ResultType == "7000222")
        by ServicePrincipalId, ServicePrincipalName
    | where ['All Error Codes'] has_all ("0", "7000222")
    QUERY

  severity    = 1
  frequency   = 60
  time_window = 60
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  tags = local.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert" "nsg_flow_log_alert" {
  name                = "${var.env}-nsg-flow-log"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  action {
    action_group = [azurerm_monitor_action_group.action_group.id]
  }

  data_source_id = data.azurerm_log_analytics_workspace.law.id
  description    = "NSG Flow log alert"
  enabled        = true
  query          = <<-QUERY
    AzureNetworkAnalytics_CL
    | extend NSGRuleAction=split(NSGRules_s, '|', 3)[0]
    | extend NSGName=tostring(split(NSGList_s, '/', 2)[0])
    | extend RG=tostring(split(NSGList_s, '/', 1)[0])
    | extend sub=tostring(split(NSGList_s, '/', 0)[0])
    | extend NSG_id=strcat("/subscriptions/", sub, "/resourceGroups/", RG, "providers/Microsoft.Network/networkSecurityGroups/", NSGName)
    | where DestPort_d == "22"
        and FASchemaVersion_s == "2"
        and NSGRuleAction == "A"
        and TimeGenerated > ago(15m)      
    | project
        TimeGenerated,
        Direction = case(FlowDirection_s == "I", "Inbound", "Outbound"),
        SourceIP = case(FlowDirection_s  == "I", case(FlowType_s in ("AzurePublic", "ExternalPublic"), split(SrcPublicIPs_s, '|', 0)[0], iif(isnotempty(SrcIP_s), SrcIP_s, "N/A")), iif(isnotempty(SrcIP_s), SrcIP_s, split(SrcPublicIPs_s, '|', 0)[0])),
        DestinationIP = case(FlowDirection_s  == "I", case(FlowType_s in ("AzurePublic", "ExternalPublic"), iif(isnotempty(VMIP_s), VMIP_s, "N/A"), DestIP_s), iif(isnotempty(DestIP_s), DestIP_s, split(DestPublicIPs_s, '|', 0)[0])),
        DestinationPort=DestPort_d,
        DestVMName = case(FlowDirection_s == "I", iif(isnotempty(VM_s), split(VM_s, '/', 1)[0], "N/A"), "N/A")
    QUERY

  severity    = 2
  frequency   = 5
  time_window = 5
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }

  tags = local.tags
}