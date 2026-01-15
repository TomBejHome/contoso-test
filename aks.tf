resource "azurerm_kubernetes_cluster" "aks" {
  name                = "contoso-aks-cluster"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = "contoso-aks"

  default_node_pool {
    name           = "nodepool1"
    node_count     = 1
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = azurerm_subnet.backend.id
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"

    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool # need to set due low rights in KodeKloud
    ]
  }

}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
output "aks_version_used" {
  value = azurerm_kubernetes_cluster.aks.kubernetes_version
}
