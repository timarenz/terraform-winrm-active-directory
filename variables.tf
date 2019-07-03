variable "dependencies" {
  type    = list(string)
  default = null
}

variable "host" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "domain_recovery_password" {
  type    = string
  default = null
}

variable "domain_name" {
  type = string
}

variable "domain_netbios_name" {
  type = string
}

variable "domain_mode" {
  type    = string
  default = 7
}

variable "forest_mode" {
  type    = string
  default = 7
}

variable "ad_users_csv" {
  type    = string
  default = null
}
