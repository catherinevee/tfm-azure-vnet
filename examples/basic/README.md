# Basic Examples

This directory contains basic examples demonstrating different use cases of the Azure VNet Terraform module.

## Examples Overview

### 1. Single VNet (`single-vnet.tf`)
The simplest example showing minimal configuration:
- Single VNet with one default subnet
- Basic resource group creation
- Minimal configuration for learning and testing

**Use Case**: Learning the module, simple applications, minimal infrastructure

### 2. Web Application (`web-app.tf`)
A typical web application architecture:
- Public subnet for web servers (DMZ)
- Private subnet for application servers
- Database subnet with restricted access
- Network Security Groups with appropriate rules
- Service endpoints for Azure services

**Use Case**: Traditional web applications, multi-tier architectures

### 3. Container Applications (`container-apps.tf`)
Container-focused architecture:
- AKS system and user node pools
- Container Apps subnet
- Database and monitoring subnets
- Service endpoints for container services
- NSGs optimized for container workloads

**Use Case**: Kubernetes deployments, container platforms, microservices

### 4. DevOps Platform (`devops.tf`)
DevOps and CI/CD infrastructure:
- Build agents subnet for CI/CD runners
- Artifact storage subnet
- Test and staging environment subnets
- Monitoring subnet for observability
- Route tables for internet access

**Use Case**: CI/CD pipelines, build infrastructure, deployment environments

### 5. Main Example (`main.tf`)
The comprehensive basic example:
- Public, private, and database subnets
- Complete NSG and route table configurations
- Service endpoints and delegations
- Demonstrates all basic features

**Use Case**: Production-ready basic deployments, feature demonstration

## Getting Started

### Prerequisites
- Azure subscription
- Terraform >= 1.0
- Azure CLI configured

### Quick Start
1. Choose an example that fits your use case
2. Copy the example file to your working directory
3. Update the variables (resource group name, location, etc.)
4. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

### Customization
Each example can be customized by:
- Changing the address spaces and subnet ranges
- Modifying NSG rules for your security requirements
- Adding or removing service endpoints
- Updating tags for your organization
- Adjusting route table configurations

## Example Configurations

### Single VNet Example
```hcl
module "single_vnet" {
  source = "../../"

  create_resource_group = true
  resource_group_name   = "rg-single-vnet-example"
  location             = "East US"

  virtual_networks = {
    main_vnet = {
      name          = "vnet-single"
      address_space = ["10.0.0.0/16"]
      subnets = [
        {
          name                = "default"
          address_prefixes    = ["10.0.0.0/24"]
        }
      ]
    }
  }
}
```

### Web Application Example
```hcl
module "web_app_vnet" {
  source = "../../"

  virtual_networks = {
    web_vnet = {
      name          = "vnet-web-app"
      address_space = ["10.1.0.0/16"]
      subnets = [
        {
          name                = "subnet-web"
          address_prefixes    = ["10.1.1.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage"]
          nsg_key            = "nsg-web"
        },
        {
          name                = "subnet-app"
          address_prefixes    = ["10.1.2.0/24"]
          service_endpoints   = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault"]
          nsg_key            = "nsg-app"
        }
      ]
    }
  }
}
```

## Cost Considerations

- **Single VNet**: Minimal cost, suitable for development
- **Web Application**: Moderate cost with NSGs and route tables
- **Container Applications**: Higher cost due to multiple subnets and service endpoints
- **DevOps Platform**: Moderate to high cost depending on environment size

## Security Best Practices

1. **Network Segmentation**: Use separate subnets for different tiers
2. **NSG Rules**: Implement least-privilege access with specific source/destination
3. **Service Endpoints**: Enable only necessary service endpoints
4. **Route Tables**: Control traffic flow with custom routes
5. **Tags**: Use consistent tagging for resource management

## Troubleshooting

### Common Issues
1. **Address Space Conflicts**: Ensure VNet address spaces don't overlap
2. **Subnet Size**: Ensure subnets are large enough for your workloads
3. **NSG Rules**: Verify NSG rules allow necessary traffic
4. **Service Endpoints**: Check if required service endpoints are enabled

### Validation
Run these commands to validate your configuration:
```bash
terraform fmt
terraform validate
terraform plan
```

## Next Steps

After deploying a basic example:
1. Review the outputs to understand resource IDs
2. Deploy compute resources in the created subnets
3. Configure additional networking features as needed
4. Consider moving to advanced examples for complex architectures

## Support

For issues or questions:
- Check the main module README for detailed documentation
- Review the advanced examples for complex scenarios
- Ensure you're using the latest module version 