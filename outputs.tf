# Azure VNet Module - Outputs
# This file contains all output definitions for the Azure VNet module

# ==============================================================================
# RESOURCE GROUP
# ==============================================================================

output "resource_group_id" {
  description = "ID of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].id : null
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].location : var.location
}

# ==============================================================================
# VIRTUAL NETWORKS
# ==============================================================================

output "virtual_networks" {
  description = "Map of virtual networks created"
  value = {
    for k, v in azurerm_virtual_network.vnet : k => {
      id              = v.id
      name            = v.name
      address_space   = v.address_space
      dns_servers     = v.dns_servers
      location        = v.location
      resource_group_name = v.resource_group_name
    }
  }
}

output "virtual_network_ids" {
  description = "Map of virtual network IDs"
  value = {
    for k, v in azurerm_virtual_network.vnet : k => v.id
  }
}

output "virtual_network_names" {
  description = "Map of virtual network names"
  value = {
    for k, v in azurerm_virtual_network.vnet : k => v.name
  }
}

# ==============================================================================
# SUBNETS
# ==============================================================================

output "subnets" {
  description = "Map of subnets created"
  value = {
    for k, v in azurerm_subnet.subnets : k => {
      id                                    = v.id
      name                                  = v.name
      address_prefixes                      = v.address_prefixes
      service_endpoints                     = v.service_endpoints
      private_endpoint_network_policies_enabled = v.private_endpoint_network_policies_enabled
      private_link_service_network_policies_enabled = v.private_link_service_network_policies_enabled
      virtual_network_name                  = v.virtual_network_name
      resource_group_name                   = v.resource_group_name
    }
  }
}

output "subnet_ids" {
  description = "Map of subnet IDs"
  value = {
    for k, v in azurerm_subnet.subnets : k => v.id
  }
}

output "subnet_names" {
  description = "Map of subnet names"
  value = {
    for k, v in azurerm_subnet.subnets : k => v.name
  }
}

# ==============================================================================
# NETWORK SECURITY GROUPS
# ==============================================================================

output "network_security_groups" {
  description = "Map of network security groups created"
  value = {
    for k, v in azurerm_network_security_group.nsg : k => {
      id                = v.id
      name              = v.name
      location          = v.location
      resource_group_name = v.resource_group_name
    }
  }
}

output "network_security_group_ids" {
  description = "Map of network security group IDs"
  value = {
    for k, v in azurerm_network_security_group.nsg : k => v.id
  }
}

output "network_security_group_names" {
  description = "Map of network security group names"
  value = {
    for k, v in azurerm_network_security_group.nsg : k => v.name
  }
}

# ==============================================================================
# ROUTE TABLES
# ==============================================================================

output "route_tables" {
  description = "Map of route tables created"
  value = {
    for k, v in azurerm_route_table.route_table : k => {
      id                = v.id
      name              = v.name
      location          = v.location
      resource_group_name = v.resource_group_name
      disable_bgp_route_propagation = v.disable_bgp_route_propagation
    }
  }
}

output "route_table_ids" {
  description = "Map of route table IDs"
  value = {
    for k, v in azurerm_route_table.route_table : k => v.id
  }
}

output "route_table_names" {
  description = "Map of route table names"
  value = {
    for k, v in azurerm_route_table.route_table : k => v.name
  }
}

# ==============================================================================
# PUBLIC IP ADDRESSES
# ==============================================================================

output "gateway_public_ips" {
  description = "Map of gateway public IP addresses created"
  value = {
    for k, v in azurerm_public_ip.gateway_pip : k => {
      id                = v.id
      name              = v.name
      ip_address        = v.ip_address
      fqdn              = v.fqdn
      allocation_method = v.allocation_method
      sku               = v.sku
      location          = v.location
      resource_group_name = v.resource_group_name
    }
  }
}

output "firewall_public_ips" {
  description = "Map of firewall public IP addresses created"
  value = {
    for k, v in azurerm_public_ip.firewall_pip : k => {
      id                = v.id
      name              = v.name
      ip_address        = v.ip_address
      fqdn              = v.fqdn
      allocation_method = v.allocation_method
      sku               = v.sku
      location          = v.location
      resource_group_name = v.resource_group_name
    }
  }
}

output "nva_public_ips" {
  description = "Map of NVA public IP addresses created"
  value = {
    for k, v in azurerm_public_ip.nva_pip : k => {
      id                = v.id
      name              = v.name
      ip_address        = v.ip_address
      fqdn              = v.fqdn
      allocation_method = v.allocation_method
      sku               = v.sku
      location          = v.location
      resource_group_name = v.resource_group_name
    }
  }
}

# ==============================================================================
# VIRTUAL NETWORK GATEWAYS
# ==============================================================================

output "vpn_gateways" {
  description = "Map of VPN gateways created"
  value = {
    for k, v in azurerm_virtual_network_gateway.vpn_gateway : k => {
      id                = v.id
      name              = v.name
      location          = v.location
      resource_group_name = v.resource_group_name
      type              = v.type
      vpn_type          = v.vpn_type
      sku               = v.sku
      enable_bgp        = v.enable_bgp
      active_active     = v.active_active
    }
  }
}

output "vpn_gateway_ids" {
  description = "Map of VPN gateway IDs"
  value = {
    for k, v in azurerm_virtual_network_gateway.vpn_gateway : k => v.id
  }
}

output "expressroute_gateways" {
  description = "Map of ExpressRoute gateways created"
  value = {
    for k, v in azurerm_virtual_network_gateway.expressroute_gateway : k => {
      id                = v.id
      name              = v.name
      location          = v.location
      resource_group_name = v.resource_group_name
      type              = v.type
      sku               = v.sku
      enable_bgp        = v.enable_bgp
    }
  }
}

output "expressroute_gateway_ids" {
  description = "Map of ExpressRoute gateway IDs"
  value = {
    for k, v in azurerm_virtual_network_gateway.expressroute_gateway : k => v.id
  }
}

# ==============================================================================
# AZURE FIREWALL
# ==============================================================================

output "azure_firewall" {
  description = "Azure Firewall details"
  value = var.azure_firewall != null ? {
    id                = azurerm_firewall.firewall[0].id
    name              = azurerm_firewall.firewall[0].name
    location          = azurerm_firewall.firewall[0].location
    resource_group_name = azurerm_firewall.firewall[0].resource_group_name
    sku_name          = azurerm_firewall.firewall[0].sku_name
    sku_tier          = azurerm_firewall.firewall[0].sku_tier
    firewall_policy_id = azurerm_firewall.firewall[0].firewall_policy_id
    private_ip_address = azurerm_firewall.firewall[0].private_ip_address
    public_ip_addresses = azurerm_firewall.firewall[0].public_ip_addresses
  } : null
}

output "azure_firewall_id" {
  description = "Azure Firewall ID"
  value       = var.azure_firewall != null ? azurerm_firewall.firewall[0].id : null
}

output "azure_firewall_name" {
  description = "Azure Firewall name"
  value       = var.azure_firewall != null ? azurerm_firewall.firewall[0].name : null
}

# ==============================================================================
# NETWORK VIRTUAL APPLIANCES (NVAs)
# ==============================================================================

output "nva_network_interfaces" {
  description = "Map of NVA network interfaces created"
  value = {
    for k, v in azurerm_network_interface.nva_nic : k => {
      id                = v.id
      name              = v.name
      location          = v.location
      resource_group_name = v.resource_group_name
      private_ip_address = v.private_ip_address
      mac_address       = v.mac_address
      enable_accelerated_networking = v.enable_accelerated_networking
      enable_ip_forwarding = v.enable_ip_forwarding
    }
  }
}

output "nva_network_interface_ids" {
  description = "Map of NVA network interface IDs"
  value = {
    for k, v in azurerm_network_interface.nva_nic : k => v.id
  }
}

output "nva_network_interface_names" {
  description = "Map of NVA network interface names"
  value = {
    for k, v in azurerm_network_interface.nva_nic : k => v.name
  }
}

# ==============================================================================
# SUMMARY OUTPUTS
# ==============================================================================

output "summary" {
  description = "Summary of all resources created"
  value = {
    resource_groups_created = var.create_resource_group ? 1 : 0
    virtual_networks_count  = length(azurerm_virtual_network.vnet)
    subnets_count          = length(azurerm_subnet.subnets)
    nsgs_count             = length(azurerm_network_security_group.nsg)
    route_tables_count     = length(azurerm_route_table.route_table)
    vpn_gateways_count     = length(azurerm_virtual_network_gateway.vpn_gateway)
    expressroute_gateways_count = length(azurerm_virtual_network_gateway.expressroute_gateway)
    azure_firewall_created = var.azure_firewall != null ? 1 : 0
    nva_network_interfaces_count = length(azurerm_network_interface.nva_nic)
    public_ips_count       = length(azurerm_public_ip.gateway_pip) + length(azurerm_public_ip.firewall_pip) + length(azurerm_public_ip.nva_pip)
  }
} 