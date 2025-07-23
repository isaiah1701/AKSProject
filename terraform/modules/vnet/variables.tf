variable "vnet_name" {}
variable "address_space" { type = list(string) }
variable "resource_group_name" {}
variable "location" {}
variable "private_subnet_name" {}
variable "private_subnet_prefix" { type = list(string) }
variable "public_subnet_name" {}
variable "public_subnet_prefix" { type = list(string) }
