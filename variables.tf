variable "subscription_id" {
  type    = string
  default = "5b1dcd77-9361-42f2-8274-db430a1dd52e"
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
  Map of team's configuration values
  EOF
  type = object({
    login     = string
    channelId = string
    groupId   = string
  })
}