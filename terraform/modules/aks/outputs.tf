output "kube_config" {
  value = azurerm_kubernetes_cluster.this.kube_config_raw
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  value       = azurerm_kubernetes_cluster.this.fqdn
  description = "The fully qualified domain name of the AKS cluster"
}

output "kubelet_identity" {
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  description = "The Object ID of the user-assigned identity used by the Kubelet"
}

output "principal_id" {
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
  description = "The Principal ID of the AKS cluster system-assigned identity"
}
