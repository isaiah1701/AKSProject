output "resource_group_name" {
  value = module.rg.name
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "dns_zone_name" {
  value = module.dns.zone_name
}

# Output input variables
output "subscription_id" {
  description = "The Azure subscription ID used"
  value       = var.subscription_id
  sensitive   = true # Mark as sensitive since it's an ID
}

output "location" {
  description = "The Azure region where resources are deployed"
  value       = var.location
}

output "domain_name" {
  description = "The DNS domain name configured"
  value       = var.domain_name
}

# Output computed values (examples)
output "vnet_id" {
  description = "The ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "aks_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks.fqdn
}

# ACR Outputs
output "acr_login_server" {
  description = "The login server URL of the Azure Container Registry"
  value       = module.acr.acr_login_server
}

output "acr_name" {
  description = "The name of the Azure Container Registry"
  value       = module.acr.acr_name
}

output "acr_admin_username" {
  description = "The admin username of the Azure Container Registry"
  value       = module.acr.acr_admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "The admin password of the Azure Container Registry"
  value       = module.acr.acr_admin_password
  sensitive   = true
}
