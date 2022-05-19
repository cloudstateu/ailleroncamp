resource "azurerm_resource_group" "rg" {
  name     = "${var.env}-rg"
  location = var.location
  tags     = local.tags
}