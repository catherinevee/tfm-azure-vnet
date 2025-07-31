# Web Application Example
# This example demonstrates a typical web application architecture with public and private subnets

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

module "web_app_vnet" {
  source = "../../"

  # Basic Configuration
  create_resource_group = true
  resource_group_name   = "rg-web-app-example"
  location             = "East US"

  tags = {
    Environment = "Development"
    Project     = "Web Application"
    Owner       = "Web Team"
    Application = "MyWebApp"
  }

  # Virtual Network for Web Application
  virtual_networks = {
    web_vnet = {
      name          = "vnet-web-app"
      address_space = ["10.1.0.0/16"]
      dns_servers   = ["168.63.129.16", "8.8.8.8"]

      subnets = [
        # Public Subnet for Web Servers
        {
          name                = "subnet-web"
          address_prefixes    = ["10.1.1.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage"]
          nsg_key            = "nsg-web"
          route_table_key    = "rt-web"
          tags = {
            purpose = "web-servers"
            tier    = "public"
          }
        },
        # Private Subnet for Application Servers
        {
          name                = "subnet-app"
          address_prefixes    = ["10.1.2.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-app"
          route_table_key    = "rt-app"
          tags = {
            purpose = "application-servers"
            tier    = "private"
          }
        },
        # Database Subnet
        {
          name                = "subnet-db"
          address_prefixes    = ["10.1.3.0/24"]
          service_endpoints   = ["Microsoft.Sql"]
          nsg_key            = "nsg-db"
          tags = {
            purpose = "database"
            tier    = "private"
          }
        }
      ]
    }
  }

  # Network Security Groups
  network_security_groups = {
    nsg-web = {
      name = "nsg-web-subnet"
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
          source_address_prefix      = "10.1.2.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-app = {
      name = "nsg-app-subnet"
      rules = [
        {
          name                       = "Allow-HTTP-From-Web"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "10.1.1.0/24"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-SSH"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.1.1.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
    nsg-db = {
      name = "nsg-db-subnet"
      rules = [
        {
          name                       = "Allow-SQL-From-App"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433"
          source_address_prefix      = "10.1.2.0/24"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  # Route Tables
  route_tables = {
    rt-web = {
      name = "rt-web-subnet"
      routes = [
        {
          name                   = "Internet-Route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type         = "Internet"
        }
      ]
    }
    rt-app = {
      name = "rt-app-subnet"
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
  value       = module.web_app_vnet.resource_group_name
}

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = values(module.web_app_vnet.virtual_networks)[0].id
}

output "web_subnet_id" {
  description = "ID of the web subnet"
  value       = module.web_app_vnet.subnet_ids["vnet-web-app/subnet-web"]
}

output "app_subnet_id" {
  description = "ID of the application subnet"
  value       = module.web_app_vnet.subnet_ids["vnet-web-app/subnet-app"]
}

output "db_subnet_id" {
  description = "ID of the database subnet"
  value       = module.web_app_vnet.subnet_ids["vnet-web-app/subnet-db"]
}

output "nsg_ids" {
  description = "IDs of all created NSGs"
  value       = module.web_app_vnet.network_security_group_ids
} 