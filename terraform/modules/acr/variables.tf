# ACR Module Variables

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]+$", var.acr_name)) && length(var.acr_name) >= 5 && length(var.acr_name) <= 50
    error_message = "ACR name must be between 5 and 50 characters, alphanumeric only."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the ACR"
  type        = string
}

variable "sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for ACR"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Enable public network access for ACR"
  type        = bool
  default     = true
}

variable "aks_principal_id" {
  description = "Principal ID of the AKS cluster for ACR pull permissions"
  type        = string
  default     = null
}

variable "argocd_principal_id" {
  description = "Principal ID of the ArgoCD service account for ACR pull permissions"
  type        = string
  default     = null
}

variable "cicd_principal_id" {
  description = "Principal ID of the CI/CD service principal for ACR push permissions"
  type        = string
  default     = null
}

variable "create_user_assigned_identity" {
  description = "Create a user-assigned managed identity for ACR"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to ACR resources"
  type        = map(string)
  default = {
    Environment = "production"
    Purpose     = "container-registry"
    ManagedBy   = "terraform"
  }
}
