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