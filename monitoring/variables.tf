variable "subscription_id" {
  type = string
}

variable "env" {
  type    = string
  default = "cs-monitoring"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "owner" {
  type    = string
  default = "JR"
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "networkwatcher-rg-name" {
  type    = string
  default = "NetworkWatcherRG"
}