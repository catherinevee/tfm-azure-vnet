# Azure VNet Terraform Module

A comprehensive Terraform module for creating Azure Virtual Networks with advanced networking features including Site-to-Site VPN Gateways, ExpressRoute Gateways, Azure Firewall, Network Virtual Appliances (NVAs), and complex routing configurations.

## Features

- **Single or Multi-VNet Support**: Create one or multiple virtual networks with customizable address spaces
- **Site-to-Site VPN Gateways**: Configure VPN gateways with BGP support and client configurations
- **ExpressRoute Gateways**: Set up ExpressRoute gateways for private connectivity
- **Azure Firewall Integration**: Deploy and configure Azure Firewall with custom policies
- **Network Virtual Appliances (NVAs)**: Support for custom network appliances with multiple network interfaces
- **Public Subnets (DMZ)**: Create public-facing subnets with appropriate security
- **Private Subnets**: Secure private subnets for internal resources
- **Route Tables**: Custom routing with support for virtual appliances and internet routing
- **Network Security Groups**: Comprehensive security rules with customizable priorities
- **Service Endpoints**: Enable service endpoints for Azure PaaS services
- **Subnet Delegations**: Support for service delegations (e.g., AKS, App Service)

## Architecture Examples

### Basic Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Single VNet Architecture                 │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Public      │  │ Private     │  │ Database    │         │
│  │ Subnet      │  │ Subnet      │  │ Subnet      │         │
│  │ (DMZ)       │  │ (Apps)      │  │ (SQL)       │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Advanced Hub-Spoke Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                  Hub-Spoke Architecture                     │
├─────────────────────────────────────────────────────────────┤
│                    ┌─────────────┐                         │
│                    │    Hub      │                         │
│                    │   VNet      │                         │
│                    │             │                         │
│  ┌─────────────┐   │ ┌─────────┐ │   ┌─────────────┐       │
│  │   Spoke 1   │◄──┤ │ Gateway │ ├──►│   Spoke 2   │       │
│  │  (Apps)     │   │ │Subnet   │ │   │   (Data)    │       │
│  └─────────────┘   │ └─────────┘ │   └─────────────┘       │
│                    │ ┌─────────┐ │                         │
│                    │ │Firewall │ │                         │
│                    │ │Subnet   │ │                         │
│                    │ └─────────┘ │                         │
│                    └─────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

## Usage

### Basic Example

```hcl
module "vnet_basic" {
  source = "./tfm-azure-vnet"

  create_resource_group = true
  resource_group_name   = "rg-vnet-example"
  location             = "East US"
  
  tags = {
    Environment = "Development"
    Project     = "VNet Module Example"
  }

  virtual_networks = {
    main_vnet = {
      name          = "vnet-main"
      address_space = ["10.0.0.0/16"]
      
      subnets = [
        {
          name                = "subnet-public"
          address_prefixes    = ["10.0.1.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage"]
          nsg_key            = "nsg-public"
          route_table_key    = "rt-public"
        },
        {
          name                = "subnet-private"
          address_prefixes    = ["10.0.2.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage"]
          nsg_key            = "nsg-private"
        }
      ]
    }
  }

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
        }
      ]
    }
  }

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
  }
}
```

### Advanced Example with All Features

```hcl
module "vnet_advanced" {
  source = "./tfm-azure-vnet"

  create_resource_group = true
  resource_group_name   = "rg-vnet-advanced"
  location             = "East US"

  # Hub-Spoke Virtual Networks
  virtual_networks = {
    hub_vnet = {
      name          = "vnet-hub"
      address_space = ["10.1.0.0/16"]
      
      subnets = [
        {
          name                = "GatewaySubnet"
          address_prefixes    = ["10.1.0.0/27"]
        },
        {
          name                = "AzureFirewallSubnet"
          address_prefixes    = ["10.1.0.32/26"]
        },
        {
          name                = "subnet-management"
          address_prefixes    = ["10.1.1.0/24"]
          nsg_key            = "nsg-management"
          route_table_key    = "rt-management"
        }
      ]
    }
    
    spoke1_vnet = {
      name          = "vnet-spoke1"
      address_space = ["10.2.0.0/16"]
      
      subnets = [
        {
          name                = "subnet-app"
          address_prefixes    = ["10.2.1.0/24"]
          nsg_key            = "nsg-app"
          route_table_key    = "rt-spoke1"
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

  # Network Virtual Appliances
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
        }
      ]
    }
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 3.0 |

## Inputs

### Basic Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create_resource_group | Whether to create a new resource group | `bool` | `true` | no |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region where resources will be created | `string` | `"East US"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |

### Virtual Networks

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| virtual_networks | Map of virtual networks to create | `map(object)` | `{}` | no |

### Network Security Groups

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network_security_groups | Map of network security groups to create | `map(object)` | `{}` | no |

### Route Tables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| route_tables | Map of route tables to create | `map(object)` | `{}` | no |

### VPN Gateways

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpn_gateways | Map of VPN gateways to create | `map(object)` | `{}` | no |

### ExpressRoute Gateways

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| expressroute_gateways | Map of ExpressRoute gateways to create | `map(object)` | `{}` | no |

### Azure Firewall

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| azure_firewall | Azure Firewall configuration | `object` | `null` | no |

### Network Virtual Appliances

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| network_virtual_appliances | Map of Network Virtual Appliances (NVAs) to create | `map(object)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_id | ID of the resource group |
| resource_group_name | Name of the resource group |
| virtual_networks | Map of virtual networks created |
| virtual_network_ids | Map of virtual network IDs |
| subnets | Map of subnets created |
| subnet_ids | Map of subnet IDs |
| network_security_groups | Map of network security groups created |
| network_security_group_ids | Map of network security group IDs |
| route_tables | Map of route tables created |
| route_table_ids | Map of route table IDs |
| vpn_gateways | Map of VPN gateways created |
| vpn_gateway_ids | Map of VPN gateway IDs |
| expressroute_gateways | Map of ExpressRoute gateways created |
| expressroute_gateway_ids | Map of ExpressRoute gateway IDs |
| azure_firewall | Azure Firewall details |
| azure_firewall_id | Azure Firewall ID |
| nva_network_interfaces | Map of NVA network interfaces created |
| nva_network_interface_ids | Map of NVA network interface IDs |
| summary | Summary of all resources created |

## Examples

### Basic Example
See the [basic example](./examples/basic/) for a simple VNet setup with subnets, NSGs, and route tables.

### Advanced Example
See the [advanced example](./examples/advanced/) for a complex hub-spoke architecture with all features enabled.

## Best Practices

### Security
- Use Network Security Groups (NSGs) to control traffic flow
- Implement the principle of least privilege for NSG rules
- Use service endpoints for secure PaaS connectivity
- Consider Azure Firewall for advanced threat protection

### Networking
- Plan your IP addressing scheme carefully
- Use route tables to control traffic flow
- Implement hub-spoke architecture for complex environments
- Use Azure Firewall or NVAs for centralized security

### Cost Optimization
- Use appropriate SKUs for gateways based on your needs
- Consider using Azure Firewall Premium only when required
- Monitor and optimize bandwidth usage

### Monitoring
- Enable NSG flow logs for traffic analysis
- Use Azure Network Watcher for troubleshooting
- Monitor gateway metrics and alerts

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For issues and questions:
1. Check the [examples](./examples/) directory
2. Review the [Terraform documentation](https://www.terraform.io/docs)
3. Check the [Azure provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

## Changelog

### Version 1.0.0
- Initial release
- Support for single and multi-VNet deployments
- VPN and ExpressRoute gateway support
- Azure Firewall integration
- Network Virtual Appliance support
- Comprehensive NSG and route table management