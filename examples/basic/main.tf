# Basic Example - Azure VNet Module
# This example demonstrates the basic usage of the Azure VNet module with:
# - Single VNet with multiple subnets
# - Network Security Groups
# - Route Tables
# - Public and Private subnets

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

# Basic VNet Configuration
module "vnet_basic" {
  source = "../../"

  # Basic Configuration
  create_resource_group = true
  resource_group_name   = "rg-vnet-basic-example"
  location             = "East US"
  
  tags = {
    Environment = "Development"
    Project     = "VNet Module Example"
    Owner       = "DevOps Team"
  }

  # Virtual Networks
  virtual_networks = {
    main_vnet = {
      name          = "vnet-main"
      address_space = ["10.0.0.0/16"]
      dns_servers   = ["168.63.129.16", "8.8.8.8"]
      
      subnets = [
        # Public Subnet (DMZ)
        {
          name                = "subnet-public"
          address_prefixes    = ["10.0.1.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage"]
          nsg_key            = "nsg-public"
          route_table_key    = "rt-public"
          tags = {
            purpose = "public-dmz"
          }
        },
        # Private Subnet
        {
          name                = "subnet-private"
          address_prefixes    = ["10.0.2.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-private"
          route_table_key    = "rt-private"
          tags = {
            purpose = "private-apps"
          }
        },
        # Database Subnet
        {
          name                = "subnet-database"
          address_prefixes    = ["10.0.3.0/24"]
          service_endpoints   = ["Microsoft.Sql"]
          nsg_key            = "nsg-database"
          tags = {
            purpose = "database"
          }
        }
      ]
    }
  }

  # Network Security Groups
  network_security_groups = {
    nsg-public = {
      name = "nsg-public"
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
          name                       = "Allow-SSH"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
    
    nsg-private = {
      name = "nsg-private"
      rules = [
        {
          name                       = "Allow-Internal-HTTP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "10.0.0.0/16"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-Internal-HTTPS"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "10.0.0.0/16"
          destination_address_prefix = "*"
        }
      ]
    }
    
    nsg-database = {
      name = "nsg-database"
      rules = [
        {
          name                       = "Allow-SQL"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.0.0.0/16"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  # Route Tables
  route_tables = {
    rt-public = {
      name = "rt-public"
      routes = [
        {
          name                   = "Internet"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "Internet"
        }
      ]
    }
    
    rt-private = {
      name = "rt-private"
      routes = [
        {
          name                   = "Internet"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "Internet"
        }
      ]
    }
  }
}

# Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.vnet_basic.resource_group_name
}

output "virtual_network_id" {
  description = "ID of the main virtual network"
  value       = module.vnet_basic.virtual_network_ids["main_vnet"]
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = module.vnet_basic.subnet_ids
}

output "nsg_ids" {
  description = "IDs of all network security groups"
  value       = module.vnet_basic.network_security_group_ids
}

output "route_table_ids" {
  description = "IDs of all route tables"
  value       = module.vnet_basic.route_table_ids
}

output "summary" {
  description = "Summary of resources created"
  value       = module.vnet_basic.summary
} 