# Configuração do Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Deploy Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "RG-AKSLABTEST"
  location = "East US"
}

# Deploy VNET
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-aks-nat-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

}

# Deploy Subnet
resource "azurerm_subnet" "sub" {
  name                 = "sub-aks01"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# #Deploy Public IP
# resource "azurerm_public_ip" "pip-nat_gateway" {
#   name                = "nat-gateway-public-ip"
#   resource_group_name = azurerm_resource_group.rg.name
#   location            = azurerm_resource_group.rg.location
#   allocation_method   = "Static"
# }

#Deploy Public IP
resource "azurerm_public_ip_prefix" "nat_prefix" {
  name                = "pip-nat-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_version          = "IPv4"
  prefix_length       = 29
  sku                 = "Standard"
  zones               = ["1"]
}


#Deploy NAT Gateway
resource "azurerm_nat_gateway" "gw_aks" {
  name                = "nat-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku_name            = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
}

#Associar Nat Gateway com Public IP
resource "azurerm_nat_gateway_public_ip_prefix_association" "nat_ips" {
  nat_gateway_id      = azurerm_nat_gateway.gw_aks.id
  public_ip_prefix_id = azurerm_public_ip_prefix.nat_prefix.id

}

resource "azurerm_subnet_nat_gateway_association" "sn_cluster_nat_gw" {
  subnet_id      = azurerm_subnet.sub.id
  nat_gateway_id = azurerm_nat_gateway.gw_aks.id
}

# Deploy AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "cluster-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "aks-teste"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  network_profile {
    network_plugin = "kubenet"
    network_policy    = "calico"
    pod_cidr     = "10.244.0.0/16"
    service_cidr = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
    load_balancer_sku = "standard"
  }
 


  service_principal {
    client_id     = "769218e9-bffc-4867-bd9f-732a5bae7b1c"
    client_secret = "9JN8Q~o~DQtUdWzL6emSs0seqbEUziWx0qPEVaLi"

  }
  
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "gateway_ips" {
  value = azurerm_public_ip_prefix.nat_prefix.ip_prefix
}
