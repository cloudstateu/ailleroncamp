resource "azurerm_virtual_network" "vnet-hub" {
  name                = "${var.env}-vnet-hub"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "vnet-hub-vm-subnet" {
  name                 = "${var.env}-subnet-01"
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "hub-vm-public-ip" {
  name                = "${var.env}-hub-vm-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "hub-vm-nsg" {
  name                = "${var.env}-hub-vm-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAll"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "hub-vm-nic" {
  name                = "${var.env}-hub-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.env}-hubvmnicconfig"
    subnet_id                     = azurerm_subnet.vnet-hub-vm-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hub-vm-public-ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "hubnsg" {
  network_interface_id      = azurerm_network_interface.hub-vm-nic.id
  network_security_group_id = azurerm_network_security_group.hub-vm-nsg.id
}

resource "azurerm_virtual_machine" "hub-vnet-vm" {
  name                  = "${var.env}-hub-vnet-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.hub-vm-nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "hub-vm-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.env}-hubvm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

data "azurerm_network_watcher" "network-watcher" {
  name                = "NetworkWatcher_westeurope"
  resource_group_name = var.networkwatcher-rg-name
}

resource "azurerm_storage_account" "saflowlogs" {
  name                = "csmonitoringsaflowlogs"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_network_watcher_flow_log" "flow-logs" {
  network_watcher_name = data.azurerm_network_watcher.network-watcher.name
  resource_group_name  = var.networkwatcher-rg-name
  name                 = "${var.env}-hub-vm-nsg-flow-log"

  network_security_group_id = azurerm_network_security_group.hub-vm-nsg.id
  storage_account_id        = azurerm_storage_account.saflowlogs.id
  location                  = azurerm_resource_group.rg.location
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 7
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.law.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.law.location
    workspace_resource_id = azurerm_log_analytics_workspace.law.id
    interval_in_minutes   = 10
  }
}