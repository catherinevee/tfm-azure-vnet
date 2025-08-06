# Azure VNet Module - Main Configuration
# Creates Azure networking infrastructure with VPN/ExpressRoute gateways, Azure Firewall, and NVAs

# ==============================================================================
# RESOURCE GROUP
# ==============================================================================

resource "azurerm_resource_group" "vnet_rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge(var.tags, {
    "module" = "azure-vnet"
    "purpose" = "networking"
  })
}

# ==============================================================================
# VIRTUAL NETWORKS
# ==============================================================================

resource "azurerm_virtual_network" "vnet" {
  for_each = var.virtual_networks

  name                = each.value.name
  resource_group_name = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  location            = each.value.location != null ? each.value.location : var.location
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  bgp_community       = each.value.bgp_community

  dynamic "ddos_protection_plan" {
    for_each = each.value.enable_ddos_protection ? [1] : []
    content {
      id     = each.value.ddos_protection_plan_id
      enable = true
    }
  }

  tags = merge(var.tags, each.value.tags, {
    "vnet_name" = each.value.name
    "module"    = "azure-vnet"
  })
}

# ==============================================================================
# SUBNETS
# ==============================================================================

resource "azurerm_subnet" "subnets" {
  for_each = {
    for subnet in local.all_subnets : "${subnet.vnet_key}.${subnet.name}" => subnet
  }

  name                 = each.value.name
  resource_group_name  = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = each.value.address_prefixes

  # Service endpoints for PaaS connectivity
  dynamic "service_endpoints" {
    for_each = each.value.service_endpoints != null ? each.value.service_endpoints : []
    content {
      service = service_endpoints.value
    }
  }

  # Private link service network policies
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  # Service delegations (AKS, App Service, etc.)
  dynamic "delegation" {
    for_each = each.value.delegations != null ? each.value.delegations : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

  tags = merge(var.tags, each.value.tags, {
    "subnet_name" = each.value.name
    "vnet_name"   = each.value.vnet_key
    "module"      = "azure-vnet"
  })
}

# ==============================================================================
# NETWORK SECURITY GROUPS
# ==============================================================================

resource "azurerm_network_security_group" "nsg" {
  for_each = var.network_security_groups

  name                = each.value.name
  location            = each.value.location != null ? each.value.location : var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name

  tags = merge(var.tags, each.value.tags, {
    "nsg_name" = each.value.name
    "module"   = "azure-vnet"
  })
}

resource "azurerm_network_security_rule" "nsg_rules" {
  for_each = {
    for rule in local.all_nsg_rules : "${rule.nsg_key}.${rule.name}" => rule
  }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  source_port_ranges          = each.value.source_port_ranges
  destination_port_ranges     = each.value.destination_port_ranges
  source_address_prefixes     = each.value.source_address_prefixes
  destination_address_prefixes = each.value.destination_address_prefixes
  resource_group_name         = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg[each.value.nsg_key].name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = {
    for subnet in local.all_subnets : "${subnet.vnet_key}.${subnet.name}" => subnet
    if subnet.nsg_key != null
  }

  subnet_id                 = azurerm_subnet.subnets["${each.value.vnet_key}.${each.value.name}"].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_key].id
}

# ==============================================================================
# ROUTE TABLES
# ==============================================================================

resource "azurerm_route_table" "route_table" {
  for_each = var.route_tables

  name                          = each.value.name
  location                      = each.value.location != null ? each.value.location : var.location
  resource_group_name           = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation

  tags = merge(var.tags, each.value.tags, {
    "route_table_name" = each.value.name
    "module"           = "azure-vnet"
  })
}

resource "azurerm_route" "route" {
  for_each = {
    for route in local.all_routes : "${route.route_table_key}.${route.name}" => route
  }

  name                   = each.value.name
  resource_group_name    = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  route_table_name       = azurerm_route_table.route_table[each.value.route_table_key].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "route_table_association" {
  for_each = {
    for subnet in local.all_subnets : "${subnet.vnet_key}.${subnet.name}" => subnet
    if subnet.route_table_key != null
  }

  subnet_id      = azurerm_subnet.subnets["${each.value.vnet_key}.${each.value.name}"].id
  route_table_id = azurerm_route_table.route_table[each.value.route_table_key].id
}

# ==============================================================================
# PUBLIC IP ADDRESSES
# ==============================================================================

resource "azurerm_public_ip" "gateway_pip" {
  for_each = {
    for gateway in local.all_gateway_public_ips : gateway.key => gateway
  }

  name                = each.value.pip_name
  location            = each.value.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  zones               = each.value.zones
  domain_name_label   = each.value.domain_name_label
  reverse_fqdn        = each.value.reverse_fqdn
  ip_version          = each.value.ip_version

  tags = merge(var.tags, each.value.tags, {
    "gateway_name" = each.value.gateway_name
    "module"       = "azure-vnet"
  })
}

resource "azurerm_public_ip" "firewall_pip" {
  for_each = var.azure_firewall != null ? var.azure_firewall.public_ips : {}

  name                = each.value.name
  location            = each.value.location != null ? each.value.location : var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  zones               = each.value.zones
  domain_name_label   = each.value.domain_name_label
  reverse_fqdn        = each.value.reverse_fqdn
  ip_version          = each.value.ip_version

  tags = merge(var.tags, each.value.tags, {
    "firewall_name" = var.azure_firewall.name
    "module"        = "azure-vnet"
  })
}

resource "azurerm_public_ip" "nva_pip" {
  for_each = {
    for nva in local.all_nva_public_ips : "${nva.nva_key}.${nva.name}" => nva
  }

  name                = each.value.name
  location            = each.value.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  zones               = each.value.zones
  domain_name_label   = each.value.domain_name_label
  reverse_fqdn        = each.value.reverse_fqdn
  ip_version          = each.value.ip_version

  tags = merge(var.tags, each.value.tags, {
    "nva_name" = each.value.nva_name
    "module"   = "azure-vnet"
  })
}

# ==============================================================================
# VIRTUAL NETWORK GATEWAYS
# ==============================================================================

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  for_each = var.vpn_gateways

  name                = each.value.name
  location            = each.value.location != null ? each.value.location : var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  type                = "Vpn"
  vpn_type            = each.value.vpn_type
  sku                 = each.value.sku
  generation          = each.value.generation
  enable_bgp          = each.value.enable_bgp
  active_active       = each.value.active_active

  # Primary IP configuration
  ip_configuration {
    name                          = each.value.ip_configuration.name
    public_ip_address_id          = azurerm_public_ip.gateway_pip[each.key].id
    private_ip_address_allocation = each.value.ip_configuration.private_ip_address_allocation
    subnet_id                     = azurerm_subnet.subnets[each.value.ip_configuration.subnet_key].id
  }

  # Secondary IP configuration for active-active
  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration.secondary_configuration != null ? [each.value.ip_configuration.secondary_configuration] : []
    content {
      name                          = ip_configuration.value.name
      public_ip_address_id          = azurerm_public_ip.gateway_pip["${each.key}_secondary"].id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      subnet_id                     = azurerm_subnet.subnets[ip_configuration.value.subnet_key].id
    }
  }

  # VPN client configuration
  dynamic "vpn_client_configuration" {
    for_each = each.value.vpn_client_configuration != null ? [each.value.vpn_client_configuration] : []
    content {
      address_space        = vpn_client_configuration.value.address_space
      aad_audience        = vpn_client_configuration.value.aad_audience
      aad_issuer          = vpn_client_configuration.value.aad_issuer
      aad_tenant          = vpn_client_configuration.value.aad_tenant
      radius_server_address = vpn_client_configuration.value.radius_server_address
      radius_server_secret  = vpn_client_configuration.value.radius_server_secret
      vpn_auth_types        = vpn_client_configuration.value.vpn_auth_types
      vpn_client_protocols  = vpn_client_configuration.value.vpn_client_protocols
    }
  }

  # BGP settings
  dynamic "bgp_settings" {
    for_each = each.value.bgp_settings != null ? [each.value.bgp_settings] : []
    content {
      asn = bgp_settings.value.asn
      peering_addresses {
        ip_configuration_name = bgp_settings.value.peering_addresses.ip_configuration_name
        apipa_addresses       = bgp_settings.value.peering_addresses.apipa_addresses
      }
      peer_weight = bgp_settings.value.peer_weight
    }
  }

  tags = merge(var.tags, each.value.tags, {
    "gateway_name" = each.value.name
    "gateway_type" = "vpn"
    "module"       = "azure-vnet"
  })
}

resource "azurerm_virtual_network_gateway" "expressroute_gateway" {
  for_each = var.expressroute_gateways

  name                = each.value.name
  location            = each.value.location != null ? each.value.location : var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  type                = "ExpressRoute"
  sku                 = each.value.sku
  enable_bgp          = each.value.enable_bgp

  # IP configuration
  ip_configuration {
    name                          = each.value.ip_configuration.name
    public_ip_address_id          = azurerm_public_ip.gateway_pip[each.key].id
    private_ip_address_allocation = each.value.ip_configuration.private_ip_address_allocation
    subnet_id                     = azurerm_subnet.subnets[each.value.ip_configuration.subnet_key].id
  }

  # BGP settings
  dynamic "bgp_settings" {
    for_each = each.value.bgp_settings != null ? [each.value.bgp_settings] : []
    content {
      asn = bgp_settings.value.asn
      peering_addresses {
        ip_configuration_name = bgp_settings.value.peering_addresses.ip_configuration_name
        apipa_addresses       = bgp_settings.value.peering_addresses.apipa_addresses
      }
      peer_weight = bgp_settings.value.peer_weight
    }
  }

  tags = merge(var.tags, each.value.tags, {
    "gateway_name" = each.value.name
    "gateway_type" = "expressroute"
    "module"       = "azure-vnet"
  })
}

# ==============================================================================
# AZURE FIREWALL
# ==============================================================================

resource "azurerm_firewall" "firewall" {
  count = var.azure_firewall != null ? 1 : 0

  name                = var.azure_firewall.name
  location            = var.azure_firewall.location != null ? var.azure_firewall.location : var.location
  resource_group_name = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  sku_name            = var.azure_firewall.sku_name
  sku_tier            = var.azure_firewall.sku_tier
  firewall_policy_id  = var.azure_firewall.firewall_policy_id
  dns_servers         = var.azure_firewall.dns_servers
  private_ip_ranges   = var.azure_firewall.private_ip_ranges
  threat_intel_mode   = var.azure_firewall.threat_intel_mode
  zones               = var.azure_firewall.zones

  # IP configurations
  dynamic "ip_configuration" {
    for_each = var.azure_firewall.ip_configurations
    content {
      name                 = ip_configuration.value.name
      subnet_id            = azurerm_subnet.subnets[ip_configuration.value.subnet_key].id
      public_ip_address_id = azurerm_public_ip.firewall_pip[ip_configuration.value.public_ip_name].id
    }
  }

  # Management IP configuration
  dynamic "management_ip_configuration" {
    for_each = var.azure_firewall.management_ip_configuration != null ? [var.azure_firewall.management_ip_configuration] : []
    content {
      name                 = management_ip_configuration.value.name
      subnet_id            = azurerm_subnet.subnets[management_ip_configuration.value.subnet_key].id
      public_ip_address_id = azurerm_public_ip.firewall_pip[management_ip_configuration.value.public_ip_name].id
    }
  }

  tags = merge(var.tags, var.azure_firewall.tags, {
    "firewall_name" = var.azure_firewall.name
    "module"        = "azure-vnet"
  })
}

# ==============================================================================
# NETWORK VIRTUAL APPLIANCES
# ==============================================================================

resource "azurerm_network_interface" "nva_nic" {
  for_each = {
    for nic in local.all_nva_nics : "${nic.nva_key}.${nic.name}" => nic
  }

  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = var.create_resource_group ? azurerm_resource_group.vnet_rg[0].name : var.resource_group_name
  enable_accelerated_networking = each.value.enable_accelerated_networking
  enable_ip_forwarding          = each.value.enable_ip_forwarding
  dns_servers                   = each.value.dns_servers

  # IP configurations
  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations
    content {
      name                          = ip_configuration.value.name
      subnet_id                     = azurerm_subnet.subnets[ip_configuration.value.subnet_key].id
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
      private_ip_address            = ip_configuration.value.private_ip_address
      public_ip_address_id          = ip_configuration.value.public_ip_name != null ? azurerm_public_ip.nva_pip["${each.value.nva_key}.${ip_configuration.value.public_ip_name}"].id : null
      primary                       = ip_configuration.value.primary
    }
  }

  tags = merge(var.tags, each.value.tags, {
    "nva_name" = each.value.nva_name
    "nic_name" = each.value.name
    "module"   = "azure-vnet"
  })
}

# ==============================================================================
# LOCALS
# ==============================================================================

locals {
  # Flatten all subnets from all VNets
  all_subnets = flatten([
    for vnet_key, vnet in var.virtual_networks : [
      for subnet in vnet.subnets : merge(subnet, {
        vnet_key = vnet_key
      })
    ]
  ])

  # Flatten all NSG rules
  all_nsg_rules = flatten([
    for nsg_key, nsg in var.network_security_groups : [
      for rule in nsg.rules : merge(rule, {
        nsg_key = nsg_key
      })
    ]
  ])

  # Flatten all routes
  all_routes = flatten([
    for rt_key, rt in var.route_tables : [
      for route in rt.routes : merge(route, {
        route_table_key = rt_key
      })
    ]
  ])

  # Flatten all gateway public IPs
  all_gateways = flatten([
    # VPN gateways
    for gw_key, gw in var.vpn_gateways : [
      {
        key              = gw_key
        gateway_name     = gw.name
        location         = gw.location != null ? gw.location : var.location
        allocation_method = "Static"
        sku              = "Standard"
        zones            = null
        domain_name_label = null
        reverse_fqdn     = null
        ip_version       = "IPv4"
        tags             = gw.tags
      }
    ],
    # ExpressRoute gateways
    for gw_key, gw in var.expressroute_gateways : [
      {
        key              = gw_key
        gateway_name     = gw.name
        location         = gw.location != null ? gw.location : var.location
        allocation_method = "Static"
        sku              = "Standard"
        zones            = null
        domain_name_label = null
        reverse_fqdn     = null
        ip_version       = "IPv4"
        tags             = gw.tags
      }
    ]
  ])

  # Generate public IP names for gateways
  all_gateway_public_ips = [
    for gw in local.all_gateways : merge(gw, {
      pip_name = "pip-${gw.gateway_name}"
    })
  ]

  # Flatten all NVA public IPs
  all_nva_public_ips = flatten([
    for nva_key, nva in var.network_virtual_appliances : [
      for pip in nva.public_ips : merge(pip, {
        nva_key  = nva_key
        nva_name = nva.name
      })
    ]
  ])

  # Flatten all NVA network interfaces
  all_nva_nics = flatten([
    for nva_key, nva in var.network_virtual_appliances : [
      for nic in nva.network_interfaces : merge(nic, {
        nva_key  = nva_key
        nva_name = nva.name
      })
    ]
  ])
} 