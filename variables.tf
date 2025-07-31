# Azure VNet Module - Variables
# This file contains all variable definitions for the Azure VNet module

# ==============================================================================
# BASIC CONFIGURATION
# ==============================================================================

variable "create_resource_group" {
  description = "Whether to create a new resource group for the VNet resources"
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the resource group (created if create_resource_group is true, otherwise must exist)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# VIRTUAL NETWORKS
# ==============================================================================

variable "virtual_networks" {
  description = "Map of virtual networks to create"
  type = map(object({
    name                    = string
    location                = optional(string)
    address_space           = list(string)
    dns_servers             = optional(list(string))
    bgp_community           = optional(string)
    enable_ddos_protection  = optional(bool, false)
    ddos_protection_plan_id = optional(string)
    tags                    = optional(map(string), {})
    subnets = list(object({
      name                                           = string
      address_prefixes                               = list(string)
      service_endpoints                              = optional(list(string))
      private_endpoint_network_policies_enabled      = optional(bool, true)
      private_link_service_network_policies_enabled  = optional(bool, true)
      nsg_key                                        = optional(string)
      route_table_key                                = optional(string)
      delegations = optional(list(object({
        name = string
        service_delegation = object({
          name    = string
          actions = list(string)
        })
      })), [])
      tags = optional(map(string), {})
    }))
  }))
  default = {}
}

# ==============================================================================
# NETWORK SECURITY GROUPS
# ==============================================================================

variable "network_security_groups" {
  description = "Map of network security groups to create"
  type = map(object({
    name     = string
    location = optional(string)
    tags     = optional(map(string), {})
    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
      source_port_ranges         = optional(list(string))
      destination_port_ranges    = optional(list(string))
      source_address_prefixes    = optional(list(string))
      destination_address_prefixes = optional(list(string))
    }))
  }))
  default = {}
}

# ==============================================================================
# ROUTE TABLES
# ==============================================================================

variable "route_tables" {
  description = "Map of route tables to create"
  type = map(object({
    name                          = string
    location                      = optional(string)
    disable_bgp_route_propagation = optional(bool, false)
    tags                          = optional(map(string), {})
    routes = list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
  default = {}
}

# ==============================================================================
# VPN GATEWAYS
# ==============================================================================

variable "vpn_gateways" {
  description = "Map of VPN gateways to create"
  type = map(object({
    name     = string
    location = optional(string)
    vpn_type = string
    sku      = string
    generation = optional(string, "Generation2")
    enable_bgp = optional(bool, false)
    active_active = optional(bool, false)
    tags     = optional(map(string), {})
    ip_configuration = object({
      name                          = string
      subnet_key                    = string
      private_ip_address_allocation = string
      secondary_configuration = optional(object({
        name                          = string
        subnet_key                    = string
        private_ip_address_allocation = string
      }))
    })
    vpn_client_configuration = optional(object({
      address_space        = list(string)
      aad_audience        = optional(string)
      aad_issuer          = optional(string)
      aad_tenant          = optional(string)
      radius_server_address = optional(string)
      radius_server_secret  = optional(string)
      vpn_auth_types        = optional(list(string))
      vpn_client_protocols  = optional(list(string))
    }))
    bgp_settings = optional(object({
      asn = number
      peering_addresses = object({
        ip_configuration_name = string
        apipa_addresses       = optional(list(string))
      })
      peer_weight = optional(number)
    }))
  }))
  default = {}
}

# ==============================================================================
# EXPRESSROUTE GATEWAYS
# ==============================================================================

variable "expressroute_gateways" {
  description = "Map of ExpressRoute gateways to create"
  type = map(object({
    name     = string
    location = optional(string)
    sku      = string
    enable_bgp = optional(bool, false)
    tags     = optional(map(string), {})
    ip_configuration = object({
      name                          = string
      subnet_key                    = string
      private_ip_address_allocation = string
    })
    bgp_settings = optional(object({
      asn = number
      peering_addresses = object({
        ip_configuration_name = string
        apipa_addresses       = optional(list(string))
      })
      peer_weight = optional(number)
    }))
  }))
  default = {}
}

# ==============================================================================
# AZURE FIREWALL
# ==============================================================================

variable "azure_firewall" {
  description = "Azure Firewall configuration"
  type = object({
    name     = string
    location = optional(string)
    sku_name = string
    sku_tier = string
    firewall_policy_id = optional(string)
    dns_servers = optional(list(string))
    private_ip_ranges = optional(list(string))
    threat_intel_mode = optional(string, "Alert")
    zones = optional(list(string))
    tags = optional(map(string), {})
    public_ips = map(object({
      name                = string
      location            = optional(string)
      allocation_method   = string
      sku                 = string
      zones               = optional(list(string))
      domain_name_label   = optional(string)
      reverse_fqdn        = optional(string)
      tags                = optional(map(string), {})
      ip_version          = optional(string, "IPv4")
    }))
    ip_configurations = list(object({
      name                 = string
      subnet_key           = string
      public_ip_name       = string
    }))
    management_ip_configuration = optional(object({
      name                 = string
      subnet_key           = string
      public_ip_name       = string
    }))
  })
  default = null
}

# ==============================================================================
# NETWORK VIRTUAL APPLIANCES (NVAs)
# ==============================================================================

variable "network_virtual_appliances" {
  description = "Map of Network Virtual Appliances (NVAs) to create"
  type = map(object({
    name     = string
    location = optional(string)
    tags     = optional(map(string), {})
    public_ips = list(object({
      name                = string
      location            = optional(string)
      allocation_method   = string
      sku                 = string
      zones               = optional(list(string))
      domain_name_label   = optional(string)
      reverse_fqdn        = optional(string)
      tags                = optional(map(string), {})
      ip_version          = optional(string, "IPv4")
    }))
    network_interfaces = list(object({
      name = string
      location = optional(string)
      tags = optional(map(string), {})
      ip_configurations = list(object({
        name                          = string
        subnet_key                    = string
        private_ip_address_allocation = string
        private_ip_address            = optional(string)
        public_ip_name                = optional(string)
        primary                       = optional(bool, false)
      }))
      enable_accelerated_networking = optional(bool, false)
      enable_ip_forwarding          = optional(bool, false)
      dns_servers                   = optional(list(string))
    }))
  }))
  default = {}
} 