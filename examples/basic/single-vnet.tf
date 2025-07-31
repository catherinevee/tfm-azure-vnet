# Single VNet Example
# This example demonstrates the most basic usage of the module with a single VNet

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

module "single_vnet" {
  source = "../../"

  # Basic Configuration
  create_resource_group = true
  resource_group_name   = "rg-single-vnet-example"
  location             = "East US"

  tags = {
    Environment = "Development"
    Project     = "Single VNet Example"
    Owner       = "DevOps Team"
  }

  # Single Virtual Network
  virtual_networks = {
    main_vnet = {
      name          = "vnet-single"
      address_space = ["10.0.0.0/16"]
      dns_servers   = ["168.63.129.16"]

      subnets = [
        # Default Subnet
        {
          name                = "default"
          address_prefixes    = ["10.0.0.0/24"]
          tags = {
            purpose = "default-subnet"
          }
        }
      ]
    }
  }
}

# Outputs
output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.single_vnet.resource_group_name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = values(module.single_vnet.virtual_networks)[0].id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = values(module.single_vnet.virtual_networks)[0].name
}

output "subnet_ids" {
  description = "IDs of all created subnets"
  value       = module.single_vnet.subnet_ids
} 