variable "subscription_id" {
  type    = string
}

variable "env" {
  type    = string
  default = "cloudsummit"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "owner" {
  type    = string
  default = "JR"
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