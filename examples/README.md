# Azure VNet Module Examples

This directory contains examples demonstrating how to use the Azure VNet Terraform module for different scenarios and architectures.

## Examples Overview

### Basic Example (`basic/`)
A simple example showing the core functionality of the module:
- Single VNet with multiple subnets
- Network Security Groups with basic rules
- Route tables for internet routing
- Public and private subnets
- Service endpoints configuration

**Use Case**: Development environments, simple applications, learning the module

### Advanced Example (`advanced/`)
A comprehensive example demonstrating all module features:
- Hub-Spoke architecture with multiple VNets
- Site-to-Site VPN Gateway with BGP
- ExpressRoute Gateway
- Azure Firewall with custom policies
- Network Virtual Appliances (NVAs)
- Complex routing configurations
- Advanced security rules

**Use Case**: Production environments, enterprise architectures, complex networking requirements

## Getting Started

### Prerequisites
1. Terraform >= 1.0
2. Azure CLI configured with appropriate permissions
3. Azure subscription with sufficient quota

### Quick Start

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd tfm-azure-vnet
   ```

2. **Choose an example**:
   ```bash
   cd examples/basic  # or examples/advanced
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Review the plan**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

### Customization

Each example can be customized by modifying the variables in the `main.tf` file:

- **Resource Group**: Change `resource_group_name` and `location`
- **Network Configuration**: Modify `virtual_networks` for different address spaces
- **Security**: Adjust `network_security_groups` rules
- **Routing**: Update `route_tables` for custom traffic flow

## Example Configurations

### Basic Example Features
```hcl
# Single VNet with 3 subnets
virtual_networks = {
  main_vnet = {
    name          = "vnet-main"
    address_space = ["10.0.0.0/16"]
    subnets = [
      # Public subnet (DMZ)
      { name = "subnet-public", address_prefixes = ["10.0.1.0/24"] },
      # Private subnet
      { name = "subnet-private", address_prefixes = ["10.0.2.0/24"] },
      # Database subnet
      { name = "subnet-database", address_prefixes = ["10.0.3.0/24"] }
    ]
  }
}
```

### Advanced Example Features
```hcl
# Hub-Spoke architecture
virtual_networks = {
  hub_vnet = {
    name          = "vnet-hub"
    address_space = ["10.1.0.0/16"]
    # Gateway and firewall subnets
  },
  spoke1_vnet = {
    name          = "vnet-spoke1"
    address_space = ["10.2.0.0/16"]
    # Application subnets
  },
  spoke2_vnet = {
    name          = "vnet-spoke2"
    address_space = ["10.3.0.0/16"]
    # Data subnets
  }
}

# VPN Gateway
vpn_gateways = {
  vpn_gateway = {
    name     = "vpn-gateway"
    vpn_type = "RouteBased"
    sku      = "VpnGw2"
    enable_bgp = true
  }
}

# Azure Firewall
azure_firewall = {
  name     = "azure-firewall"
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"
}
```

## Cost Considerations

### Basic Example
- **Estimated Cost**: $10-50/month
- **Resources**: VNet, subnets, NSGs, route tables
- **No Gateway Costs**: Uses internet routing

### Advanced Example
- **Estimated Cost**: $500-2000/month
- **Resources**: Multiple VNets, VPN Gateway, ExpressRoute Gateway, Azure Firewall, NVAs
- **Gateway Costs**: VPN Gateway ($27-540/month), ExpressRoute Gateway ($27-540/month)
- **Firewall Costs**: Azure Firewall ($1.25/hour + data processing)

## Security Best Practices

### Basic Example
- Use NSGs to restrict traffic
- Implement service endpoints for PaaS services
- Apply least privilege principles

### Advanced Example
- Use Azure Firewall for centralized security
- Implement hub-spoke architecture for traffic control
- Use NVAs for specialized security requirements
- Enable BGP for dynamic routing

## Troubleshooting

### Common Issues

1. **Insufficient Quota**:
   ```bash
   # Check your subscription limits
   az vm list-usage --location "East US"
   ```

2. **Gateway Subnet Issues**:
   - Ensure GatewaySubnet is /27 or larger
   - Don't associate NSGs with GatewaySubnet

3. **Firewall Configuration**:
   - AzureFirewallSubnet must be /26
   - Requires dedicated subnet

4. **NVA Configuration**:
   - Enable IP forwarding on NVA network interfaces
   - Configure proper routing tables

### Useful Commands

```bash
# Check resource group
az group show --name rg-vnet-example

# List virtual networks
az network vnet list --resource-group rg-vnet-example

# Check NSG rules
az network nsg rule list --nsg-name nsg-public --resource-group rg-vnet-example

# Test connectivity
az network watcher test-connectivity --resource-group rg-vnet-example --source-resource <vm-id> --dest-resource <target-id>
```

## Next Steps

After deploying an example:

1. **Connect Resources**: Deploy VMs, App Services, or other resources to the subnets
2. **Configure Peering**: Set up VNet peering if using multiple VNets
3. **Monitor**: Enable NSG flow logs and Azure Monitor
4. **Scale**: Add more subnets or VNets as needed

## Contributing Examples

To add new examples:

1. Create a new directory under `examples/`
2. Include a `main.tf` file with complete configuration
3. Add a `README.md` explaining the use case
4. Update this README with the new example

## Support

For issues with the examples:
1. Check the main module [README](../README.md)
2. Review Azure documentation
3. Open an issue in the repository 