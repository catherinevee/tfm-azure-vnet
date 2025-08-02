# Basic VNet Module Tests
# This file contains basic tests for the Azure VNet module

run "basic_vnet_deployment" {
  command = plan

  variables {
    create_resource_group = true
    resource_group_name   = "test-rg-vnet-basic"
    location             = "East US"
    
    tags = {
      Environment = "Test"
      Project     = "VNet Module Testing"
    }

    virtual_networks = {
      test_vnet = {
        name          = "test-vnet-basic"
        address_space = ["10.0.0.0/16"]
        dns_servers   = ["168.63.129.16"]
        
        subnets = [
          {
            name             = "test-subnet"
            address_prefixes = ["10.0.1.0/24"]
            service_endpoints = ["Microsoft.Web"]
          }
        ]
      }
    }
  }

  assert {
    condition     = plan.outputs.virtual_network_ids["test_vnet"] != null
    error_message = "Virtual network should be created with valid ID"
  }

  assert {
    condition     = plan.outputs.subnet_ids["test_vnet.test-subnet"] != null
    error_message = "Subnet should be created with valid ID"
  }

  assert {
    condition     = plan.outputs.resource_group_name == "test-rg-vnet-basic"
    error_message = "Resource group name should match expected value"
  }
}

run "vnet_with_nsg" {
  command = plan

  variables {
    create_resource_group = true
    resource_group_name   = "test-rg-vnet-nsg"
    location             = "East US"
    
    tags = {
      Environment = "Test"
      Project     = "VNet Module Testing"
    }

    virtual_networks = {
      test_vnet = {
        name          = "test-vnet-nsg"
        address_space = ["10.0.0.0/16"]
        
        subnets = [
          {
            name             = "test-subnet"
            address_prefixes = ["10.0.1.0/24"]
            nsg_key          = "test-nsg"
          }
        ]
      }
    }

    network_security_groups = {
      test-nsg = {
        name = "test-nsg"
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
          }
        ]
      }
    }
  }

  assert {
    condition     = plan.outputs.network_security_group_ids["test-nsg"] != null
    error_message = "Network security group should be created with valid ID"
  }

  assert {
    condition     = length(plan.outputs.network_security_groups["test-nsg"]) > 0
    error_message = "Network security group should have configuration data"
  }
}

run "vnet_with_routing" {
  command = plan

  variables {
    create_resource_group = true
    resource_group_name   = "test-rg-vnet-routing"
    location             = "East US"
    
    tags = {
      Environment = "Test"
      Project     = "VNet Module Testing"
    }

    virtual_networks = {
      test_vnet = {
        name          = "test-vnet-routing"
        address_space = ["10.0.0.0/16"]
        
        subnets = [
          {
            name             = "test-subnet"
            address_prefixes = ["10.0.1.0/24"]
            route_table_key  = "test-rt"
          }
        ]
      }
    }

    route_tables = {
      test-rt = {
        name = "test-rt"
        routes = [
          {
            name           = "Internet"
            address_prefix = "0.0.0.0/0"
            next_hop_type  = "Internet"
          }
        ]
      }
    }
  }

  assert {
    condition     = plan.outputs.route_table_ids["test-rt"] != null
    error_message = "Route table should be created with valid ID"
  }

  assert {
    condition     = length(plan.outputs.route_tables["test-rt"]) > 0
    error_message = "Route table should have configuration data"
  }
}

run "multi_vnet_deployment" {
  command = plan

  variables {
    create_resource_group = true
    resource_group_name   = "test-rg-multi-vnet"
    location             = "East US"
    
    tags = {
      Environment = "Test"
      Project     = "VNet Module Testing"
    }

    virtual_networks = {
      hub_vnet = {
        name          = "test-hub-vnet"
        address_space = ["10.0.0.0/16"]
        
        subnets = [
          {
            name             = "hub-subnet"
            address_prefixes = ["10.0.1.0/24"]
          }
        ]
      }
      
      spoke_vnet = {
        name          = "test-spoke-vnet"
        address_space = ["10.1.0.0/16"]
        
        subnets = [
          {
            name             = "spoke-subnet"
            address_prefixes = ["10.1.1.0/24"]
          }
        ]
      }
    }
  }

  assert {
    condition     = length(plan.outputs.virtual_network_ids) == 2
    error_message = "Should create exactly 2 virtual networks"
  }

  assert {
    condition     = plan.outputs.virtual_network_ids["hub_vnet"] != null
    error_message = "Hub VNet should be created"
  }

  assert {
    condition     = plan.outputs.virtual_network_ids["spoke_vnet"] != null
    error_message = "Spoke VNet should be created"
  }
}

run "summary_output_validation" {
  command = plan

  variables {
    create_resource_group = true
    resource_group_name   = "test-rg-summary"
    location             = "East US"
    
    virtual_networks = {
      test_vnet = {
        name          = "test-vnet-summary"
        address_space = ["10.0.0.0/16"]
        
        subnets = [
          {
            name             = "test-subnet"
            address_prefixes = ["10.0.1.0/24"]
          }
        ]
      }
    }
  }

  assert {
    condition     = plan.outputs.summary != null
    error_message = "Summary output should be provided"
  }

  assert {
    condition     = can(plan.outputs.summary.virtual_networks)
    error_message = "Summary should include virtual networks count"
  }

  assert {
    condition     = can(plan.outputs.summary.subnets)
    error_message = "Summary should include subnets count"
  }
} 