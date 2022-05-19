variable "subscription_id" {
  type = string
}

variable "env" {
  type    = string
  default = "cs-alerts"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "owner" {
  type    = string
  default = "JR"
}

variable "law-env" {
  type    = string
  default = "cs-monitoring"
}

variable "teams_config" {
  description = <<EOF
  MS Teams configuration data
  EOF
  type = object({
    login     = string
    channelId = string
    groupId   = string
  })
}