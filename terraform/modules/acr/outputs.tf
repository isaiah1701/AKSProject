# ACR Module Outputs

output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  description = "Login server URL of the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Admin username of the Azure Container Registry"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password of the Azure Container Registry"
  value       = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  sensitive   = true
}

output "acr_sku" {
  description = "SKU of the Azure Container Registry"
  value       = azurerm_container_registry.acr.sku
}

output "acr_resource_group_name" {
  description = "Resource group name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.resource_group_name
}

output "acr_location" {
  description = "Location of the Azure Container Registry"
  value       = azurerm_container_registry.acr.location
}

# Role assignment outputs
output "aks_acr_role_assignment_id" {
  description = "ID of the AKS to ACR role assignment"
  value       = var.aks_principal_id != null ? azurerm_role_assignment.aks_acr_pull[0].id : null
}

output "argocd_acr_role_assignment_id" {
  description = "ID of the ArgoCD to ACR role assignment"
  value       = var.argocd_principal_id != null ? azurerm_role_assignment.argocd_acr_pull[0].id : null
}

output "cicd_acr_role_assignment_id" {
  description = "ID of the CI/CD to ACR role assignment"
  value       = var.cicd_principal_id != null ? azurerm_role_assignment.cicd_acr_push[0].id : null
}

# Outputs for ArgoCD configuration
output "argocd_registry_config" {
  description = "Configuration block for ArgoCD to access ACR"
  value = {
    server   = azurerm_container_registry.acr.login_server
    username = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
    password = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  }
  sensitive = true
}

# Output for CI/CD pipeline configuration
output "cicd_registry_config" {
  description = "Configuration for CI/CD pipelines to push to ACR"
  value = {
    registry_name = azurerm_container_registry.acr.name
    login_server  = azurerm_container_registry.acr.login_server
  }
}

output "container_registry_url" {
  description = "Full URL for container images (for use in Kubernetes manifests)"
  value       = azurerm_container_registry.acr.login_server
}

# Output for updating GitHub secrets
output "github_secrets_config" {
  description = "Configuration values to add to GitHub secrets for CI/CD"
  value = {
    ACR_REGISTRY = azurerm_container_registry.acr.login_server
    ACR_USERNAME = var.admin_enabled ? azurerm_container_registry.acr.admin_username : null
    ACR_PASSWORD = var.admin_enabled ? azurerm_container_registry.acr.admin_password : null
  }
  sensitive = true
}
