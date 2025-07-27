variable "cluster_name" {}
variable "dns_prefix" {}
variable "location" {}
variable "resource_group_name" {}
variable "node_count" { default = 2 }
variable "vm_size" { default = "Standard_B2s" } # 2 vCPUs instead of 4
variable "subnet_id" {}
