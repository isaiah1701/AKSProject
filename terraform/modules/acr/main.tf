# Azure Container Registry Module
# This module creates an ACR instance that can be used by AKS and ArgoCD

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                          = var.acr_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled

  tags = var.tags
}

# Create role assignment for AKS to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.aks_principal_id != null ? 1 : 0
  principal_id         = var.aks_principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  
  depends_on = [azurerm_container_registry.acr]
}

# Create role assignment for ArgoCD service account to pull from ACR
resource "azurerm_role_assignment" "argocd_acr_pull" {
  count                = var.argocd_principal_id != null ? 1 : 0
  principal_id         = var.argocd_principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  
  depends_on = [azurerm_container_registry.acr]
}

# Create role assignment for CI/CD service principal
resource "azurerm_role_assignment" "cicd_acr_push" {
  count                = var.cicd_principal_id != null ? 1 : 0
  principal_id         = var.cicd_principal_id
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.acr.id
  
  depends_on = [azurerm_container_registry.acr]
}

# Optional: Create a user-assigned managed identity for ACR
resource "azurerm_user_assigned_identity" "acr_identity" {
  count               = var.create_user_assigned_identity ? 1 : 0
  name                = "${var.acr_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = var.tags
}
