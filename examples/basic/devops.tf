# DevOps Example
# This example demonstrates a DevOps-focused architecture with build agents and deployment environments

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

module "devops_vnet" {
  source = "../../"

  # Basic Configuration
  create_resource_group = true
  resource_group_name   = "rg-devops-example"
  location             = "East US"

  tags = {
    Environment = "Development"
    Project     = "DevOps Platform"
    Owner       = "DevOps Team"
    Purpose     = "CI/CD Infrastructure"
  }

  # Virtual Network for DevOps Platform
  virtual_networks = {
    devops_vnet = {
      name          = "vnet-devops"
      address_space = ["10.3.0.0/16"]
      dns_servers   = ["168.63.129.16", "8.8.8.8"]

      subnets = [
        # Build Agents Subnet
        {
          name                = "subnet-build-agents"
          address_prefixes    = ["10.3.1.0/24"]
          service_endpoints   = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
          nsg_key            = "nsg-build-agents"
          route_table_key    = "rt-build-agents"
          tags = {
            purpose = "build-agents"
            tier    = "compute"
          }
        },
        # Artifact Storage Subnet
        {
          name                = "subnet-artifacts"
          address_prefixes    = ["10.3.2.0/24"]
          service_endpoints   = ["Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-artifacts"
          tags = {
            purpose = "artifact-storage"
            tier    = "storage"
          }
        },
        # Test Environment Subnet
        {
          name                = "subnet-test"
          address_prefixes    = ["10.3.3.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
          nsg_key            = "nsg-test"
          route_table_key    = "rt-test"
          tags = {
            purpose = "test-environment"
            tier    = "testing"
          }
        },
        # Staging Environment Subnet
        {
          name                = "subnet-staging"
          address_prefixes    = ["10.3.4.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
          nsg_key            = "nsg-staging"
          route_table_key    = "rt-staging"
          tags = {
            purpose = "staging-environment"
            tier    = "staging"
          }
        },
        # Monitoring Subnet
        {
          name                = "subnet-monitoring"
          address_prefixes    = ["10.3.5.0/24"]
          service_endpoints   = ["Microsoft.OperationalInsights", "Microsoft.KeyVault", "Microsoft.Storage"]
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
    nsg-build-agents = {
      name = "nsg-build-agents"
      rules = [
        {
          name                       = "Allow-SSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.3.5.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-RDP"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefix      = "10.3.5.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-HTTP"
          priority                   = 120
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
          priority                   = 130
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
    nsg-artifacts = {
      name = "nsg-artifacts"
      rules = [
        {
          name                       = "Allow-Storage-From-Build"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "445"
          source_address_prefix      = "10.3.1.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-Storage-From-Test"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "445"
          source_address_prefix      = "10.3.3.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-Storage-From-Staging"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "445"
          source_address_prefix      = "10.3.4.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-test = {
      name = "nsg-test"
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
        },
        {
          name                       = "Allow-SSH-From-Build"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.3.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-staging = {
      name = "nsg-staging"
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
        },
        {
          name                       = "Allow-SSH-From-Build"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.3.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-monitoring = {
      name = "nsg-monitoring"
      rules = [
        {
          name                       = "Allow-Monitoring-From-All"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8125"
          source_address_prefix      = "10.3.0.0/16"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-SSH-From-Monitoring"
          priority                   = 110
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "10.3.0.0/16"
        }
      ]
    }
  }

  # Route Tables
  route_tables = {
    rt-build-agents = {
      name = "rt-build-agents"
      routes = [
        {
          name                   = "Internet-Route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type         = "Internet"
        }
      ]
    }
    rt-test = {
      name = "rt-test"
      routes = [
        {
          name                   = "Internet-Route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type         = "Internet"
        }
      ]
    }
    rt-staging = {
      name = "rt-staging"
      routes = [
        {
          name                   = "Internet-Route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type         = "Internet"
        }
      ]
    }
  }
}

# Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.devops_vnet.resource_group_name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = values(module.devops_vnet.virtual_networks)[0].id
}

output "build_agents_subnet_id" {
  description = "ID of the build agents subnet"
  value       = module.devops_vnet.subnet_ids["vnet-devops/subnet-build-agents"]
}

output "artifacts_subnet_id" {
  description = "ID of the artifacts subnet"
  value       = module.devops_vnet.subnet_ids["vnet-devops/subnet-artifacts"]
}

output "test_subnet_id" {
  description = "ID of the test environment subnet"
  value       = module.devops_vnet.subnet_ids["vnet-devops/subnet-test"]
}

output "staging_subnet_id" {
  description = "ID of the staging environment subnet"
  value       = module.devops_vnet.subnet_ids["vnet-devops/subnet-staging"]
}

output "monitoring_subnet_id" {
  description = "ID of the monitoring subnet"
  value       = module.devops_vnet.subnet_ids["vnet-devops/subnet-monitoring"]
}

output "route_table_ids" {
  description = "IDs of all created route tables"
  value       = module.devops_vnet.route_table_ids
} 