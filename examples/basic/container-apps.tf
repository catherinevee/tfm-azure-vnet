# Container Applications Example
# This example demonstrates a container-focused architecture with AKS and Container Apps

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "container_vnet" {
  source = "../../"

  # Basic Configuration
  create_resource_group = true
  resource_group_name   = "rg-container-example"
  location             = "East US"

  tags = {
    Environment = "Development"
    Project     = "Container Platform"
    Owner       = "Platform Team"
    Platform    = "Kubernetes"
  }

  # Virtual Network for Container Applications
  virtual_networks = {
    container_vnet = {
      name          = "vnet-container"
      address_space = ["10.2.0.0/16"]
      dns_servers   = ["168.63.129.16"]

      subnets = [
        # AKS System Subnet
        {
          name                = "subnet-aks-system"
          address_prefixes    = ["10.2.1.0/24"]
          service_endpoints   = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
          nsg_key            = "nsg-aks-system"
          tags = {
            purpose = "aks-system-nodes"
            tier    = "system"
          }
        },
        # AKS User Subnet
        {
          name                = "subnet-aks-user"
          address_prefixes    = ["10.2.2.0/24"]
          service_endpoints   = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Storage"]
          nsg_key            = "nsg-aks-user"
          tags = {
            purpose = "aks-user-nodes"
            tier    = "user"
          }
        },
        # Container Apps Subnet
        {
          name                = "subnet-container-apps"
          address_prefixes    = ["10.2.3.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-container-apps"
          tags = {
            purpose = "container-apps"
            tier    = "application"
          }
        },
        # Database Subnet
        {
          name                = "subnet-database"
          address_prefixes    = ["10.2.4.0/24"]
          service_endpoints   = ["Microsoft.Sql", "Microsoft.KeyVault"]
          nsg_key            = "nsg-database"
          tags = {
            purpose = "database"
            tier    = "data"
          }
        },
        # Monitoring Subnet
        {
          name                = "subnet-monitoring"
          address_prefixes    = ["10.2.5.0/24"]
          service_endpoints   = ["Microsoft.OperationalInsights", "Microsoft.KeyVault"]
          nsg_key            = "nsg-monitoring"
          tags = {
            purpose = "monitoring"
            tier    = "management"
          }
        }
      ]
    }
  }

  # Network Security Groups
  network_security_groups = {
    nsg-aks-system = {
      name = "nsg-aks-system"
      rules = [
        {
          name                       = "Allow-AKS-API"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "AzureLoadBalancer"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-AKS-Nodes"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "10250"
          source_address_prefix      = "10.2.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-aks-user = {
      name = "nsg-aks-user"
      rules = [
        {
          name                       = "Allow-HTTP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-HTTPS"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-container-apps = {
      name = "nsg-container-apps"
      rules = [
        {
          name                       = "Allow-HTTP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-HTTPS"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-database = {
      name = "nsg-database"
      rules = [
        {
          name                       = "Allow-SQL-From-Apps"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.2.2.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-SQL-From-Container-Apps"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.2.3.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-monitoring = {
      name = "nsg-monitoring"
      rules = [
        {
          name                       = "Allow-Monitoring-From-Apps"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8125"
          source_address_prefix      = "10.2.2.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-Monitoring-From-Container-Apps"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8125"
          source_address_prefix      = "10.2.3.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
  }
}

# Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.container_vnet.resource_group_name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = values(module.container_vnet.virtual_networks)[0].id
}

output "aks_system_subnet_id" {
  description = "ID of the AKS system subnet"
  value       = module.container_vnet.subnet_ids["vnet-container/subnet-aks-system"]
}

output "aks_user_subnet_id" {
  description = "ID of the AKS user subnet"
  value       = module.container_vnet.subnet_ids["vnet-container/subnet-aks-user"]
}

output "container_apps_subnet_id" {
  description = "ID of the Container Apps subnet"
  value       = module.container_vnet.subnet_ids["vnet-container/subnet-container-apps"]
}

output "database_subnet_id" {
  description = "ID of the database subnet"
  value       = module.container_vnet.subnet_ids["vnet-container/subnet-database"]
}

output "monitoring_subnet_id" {
  description = "ID of the monitoring subnet"
  value       = module.container_vnet.subnet_ids["vnet-container/subnet-monitoring"]
}

output "all_subnet_ids" {
  description = "All subnet IDs"
  value       = module.container_vnet.subnet_ids
} 