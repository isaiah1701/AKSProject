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
