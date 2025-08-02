# Advanced Example - Azure VNet Module
# This example demonstrates advanced usage of the Azure VNet module with:
# - Multiple VNets (Hub-Spoke architecture)
# - Site-to-Site VPN Gateway
# - ExpressRoute Gateway
# - Azure Firewall
# - Network Virtual Appliances (NVAs)
# - Complex routing and security

terraform {
  required_version = ">= 1.13.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.38.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Advanced VNet Configuration with Hub-Spoke Architecture
module "vnet_advanced" {
  source = "../../"

  # Basic Configuration
  create_resource_group = true
  resource_group_name   = "rg-vnet-advanced-example"
  location             = "East US"
  
  tags = {
    Environment = "Production"
    Project     = "Advanced VNet Architecture"
    Owner       = "Network Team"
    CostCenter  = "IT-001"
  }

  # Virtual Networks - Hub-Spoke Architecture
  virtual_networks = {
    # Hub VNet
    hub_vnet = {
      name          = "vnet-hub"
      address_space = ["10.1.0.0/16"]
      dns_servers   = ["168.63.129.16", "8.8.8.8"]
      
      subnets = [
        # Gateway Subnet for VPN/ExpressRoute
        {
          name                = "GatewaySubnet"
          address_prefixes    = ["10.1.0.0/27"]
          tags = {
            purpose = "gateway-subnet"
          }
        },
        # Azure Firewall Subnet
        {
          name                = "AzureFirewallSubnet"
          address_prefixes    = ["10.1.0.32/26"]
          tags = {
            purpose = "firewall-subnet"
          }
        },
        # Management Subnet
        {
          name                = "subnet-management"
          address_prefixes    = ["10.1.1.0/24"]
          service_endpoints   = ["Microsoft.KeyVault", "Microsoft.Storage"]
          nsg_key            = "nsg-management"
          route_table_key    = "rt-management"
          tags = {
            purpose = "management"
          }
        },
        # Shared Services Subnet
        {
          name                = "subnet-shared"
          address_prefixes    = ["10.1.2.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-shared"
          route_table_key    = "rt-shared"
          tags = {
            purpose = "shared-services"
          }
        }
      ]
    }
    
    # Spoke 1 VNet - Application
    spoke1_vnet = {
      name          = "vnet-spoke1-app"
      address_space = ["10.2.0.0/16"]
      dns_servers   = ["168.63.129.16"]
      
      subnets = [
        # Application Subnet
        {
          name                = "subnet-app"
          address_prefixes    = ["10.2.1.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-app"
          route_table_key    = "rt-spoke1"
          tags = {
            purpose = "application"
          }
        },
        # Database Subnet
        {
          name                = "subnet-db"
          address_prefixes    = ["10.2.2.0/24"]
          service_endpoints   = ["Microsoft.Sql"]
          nsg_key            = "nsg-database"
          tags = {
            purpose = "database"
          }
        }
      ]
    }
    
    # Spoke 2 VNet - Data
    spoke2_vnet = {
      name          = "vnet-spoke2-data"
      address_space = ["10.3.0.0/16"]
      dns_servers   = ["168.63.129.16"]
      
      subnets = [
        # Data Processing Subnet
        {
          name                = "subnet-data"
          address_prefixes    = ["10.3.1.0/24"]
          service_endpoints   = ["Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-data"
          route_table_key    = "rt-spoke2"
          tags = {
            purpose = "data-processing"
          }
        },
        # Analytics Subnet
        {
          name                = "subnet-analytics"
          address_prefixes    = ["10.3.2.0/24"]
          service_endpoints   = ["Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-analytics"
          tags = {
            purpose = "analytics"
          }
        }
      ]
    }
  }

  # Network Security Groups
  network_security_groups = {
    nsg-management = {
      name = "nsg-management"
      rules = [
        {
          name                       = "Allow-SSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "10.1.0.0/16"
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
          source_address_prefix      = "10.1.0.0/16"
          destination_address_prefix = "*"
        }
      ]
    }
    
    nsg-shared = {
      name = "nsg-shared"
      rules = [
        {
          name                       = "Allow-Internal-HTTP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "10.0.0.0/8"
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
          source_address_prefix      = "10.0.0.0/8"
          destination_address_prefix = "*"
        }
      ]
    }
    
    nsg-app = {
      name = "nsg-app"
      rules = [
        {
          name                       = "Allow-App-HTTP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "10.0.0.0/8"
          destination_address_prefix = "*"
        },
        {
          name                       = "Allow-App-HTTPS"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = "10.0.0.0/8"
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
          source_address_prefix      = "10.0.0.0/8"
          destination_address_prefix = "*"
        }
      ]
    }
    
    nsg-data = {
      name = "nsg-data"
      rules = [
        {
          name                       = "Allow-Data-Processing"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.0.0.0/8"
          destination_address_prefix = "*"
        }
      ]
    }
    
    nsg-analytics = {
      name = "nsg-analytics"
      rules = [
        {
          name                       = "Allow-Analytics"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "9000"
          source_address_prefix      = "10.0.0.0/8"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  # Route Tables
  route_tables = {
    rt-management = {
      name = "rt-management"
      routes = [
        {
          name                   = "Internet"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "Internet"
        }
      ]
    }
    
    rt-shared = {
      name = "rt-shared"
      routes = [
        {
          name                   = "Internet"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "Internet"
        }
      ]
    }
    
    rt-spoke1 = {
      name = "rt-spoke1"
      routes = [
        {
          name                   = "Internet"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.1.0.4" # Azure Firewall IP
        }
      ]
    }
    
    rt-spoke2 = {
      name = "rt-spoke2"
      routes = [
        {
          name                   = "Internet"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.1.0.4" # Azure Firewall IP
        }
      ]
    }
  }

  # VPN Gateway
  vpn_gateways = {
    vpn_gateway = {
      name     = "vpn-gateway"
      vpn_type = "RouteBased"
      sku      = "VpnGw2"
      enable_bgp = true
      
      ip_configuration = {
        name                          = "vpnGatewayConfig"
        subnet_key                    = "hub_vnet.GatewaySubnet"
        private_ip_address_allocation = "Dynamic"
      }
      
      vpn_client_configuration = {
        address_space = ["172.16.0.0/24"]
        vpn_auth_types = ["Certificate"]
        vpn_client_protocols = ["OpenVPN"]
      }
      
      bgp_settings = {
        asn = 65515
        peering_addresses = {
          ip_configuration_name = "vpnGatewayConfig"
        }
      }
    }
  }

  # ExpressRoute Gateway
  expressroute_gateways = {
    er_gateway = {
      name     = "er-gateway"
      sku      = "Standard"
      enable_bgp = true
      
      ip_configuration = {
        name                          = "erGatewayConfig"
        subnet_key                    = "hub_vnet.GatewaySubnet"
        private_ip_address_allocation = "Dynamic"
      }
      
      bgp_settings = {
        asn = 65515
        peering_addresses = {
          ip_configuration_name = "erGatewayConfig"
        }
      }
    }
  }

  # Azure Firewall
  azure_firewall = {
    name     = "azure-firewall"
    sku_name = "AZFW_VNet"
    sku_tier = "Standard"
    
    public_ips = {
      firewall_pip = {
        name              = "pip-firewall"
        allocation_method = "Static"
        sku               = "Standard"
      }
    }
    
    ip_configurations = [
      {
        name           = "firewall-ipconfig"
        subnet_key     = "hub_vnet.AzureFirewallSubnet"
        public_ip_name = "firewall_pip"
      }
    ]
  }

  # Network Virtual Appliances (NVAs)
  network_virtual_appliances = {
    nva1 = {
      name = "nva1"
      
      public_ips = [
        {
          name              = "pip-nva1"
          allocation_method = "Static"
          sku               = "Standard"
        }
      ]
      
      network_interfaces = [
        {
          name = "nic-nva1-primary"
          ip_configurations = [
            {
              name                          = "ipconfig1"
              subnet_key                    = "hub_vnet.subnet-management"
              private_ip_address_allocation = "Static"
              private_ip_address            = "10.1.1.10"
              public_ip_name                = "pip-nva1"
              primary                       = true
            }
          ]
          enable_ip_forwarding = true
        },
        {
          name = "nic-nva1-secondary"
          ip_configurations = [
            {
              name                          = "ipconfig2"
              subnet_key                    = "hub_vnet.subnet-shared"
              private_ip_address_allocation = "Static"
              private_ip_address            = "10.1.2.10"
              primary                       = false
            }
          ]
          enable_ip_forwarding = true
        }
      ]
    }
  }
}

# Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.vnet_advanced.resource_group_name
}

output "virtual_network_ids" {
  description = "IDs of all virtual networks"
  value       = module.vnet_advanced.virtual_network_ids
}

output "subnet_ids" {
  description = "IDs of all subnets"
  value       = module.vnet_advanced.subnet_ids
}

output "vpn_gateway_id" {
  description = "ID of the VPN gateway"
  value       = module.vnet_advanced.vpn_gateway_ids["vpn_gateway"]
}

output "expressroute_gateway_id" {
  description = "ID of the ExpressRoute gateway"
  value       = module.vnet_advanced.expressroute_gateway_ids["er_gateway"]
}

output "azure_firewall_id" {
  description = "ID of the Azure Firewall"
  value       = module.vnet_advanced.azure_firewall_id
}

output "nva_network_interface_ids" {
  description = "IDs of NVA network interfaces"
  value       = module.vnet_advanced.nva_network_interface_ids
}

output "summary" {
  description = "Summary of resources created"
  value       = module.vnet_advanced.summary
} 