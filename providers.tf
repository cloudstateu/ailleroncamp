terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0.9"
}

provider "azurerm" {
  features {}
  subscription_id = "5b1dcd77-9361-42f2-8274-db430a1dd52e"
}