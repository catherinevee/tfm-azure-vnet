# VNet Module Tests

This directory contains tests for the Azure VNet Terraform module using native Terraform testing framework.

## Test Structure

### `basic.tftest.hcl`
Contains basic functionality tests that validate:
- Basic VNet deployment with subnets
- Network Security Group integration
- Route table configuration
- Multi-VNet deployments
- Output validation

## Running Tests

### Prerequisites
- Terraform >= 1.13.0
- Azure provider ~> 4.38.1
- Azure CLI configured with appropriate permissions

### Test Execution

```bash
# Run all tests
terraform test

# Run specific test file
terraform test tests/basic.tftest.hcl

# Run with verbose output
terraform test -verbose
```

### Test Types

#### Plan Tests
Most tests use `command = plan` to validate:
- Resource creation logic
- Variable processing
- Output generation
- Configuration validation

#### Apply Tests (Future)
For integration testing, consider adding apply tests:
```hcl
run "integration_test" {
  command = apply
  
  # Cleanup after test
  cleanup = true
}
```

## Test Coverage

### Core Functionality
- ✅ Virtual network creation
- ✅ Subnet configuration
- ✅ Network security groups
- ✅ Route tables
- ✅ Multi-VNet scenarios

### Planned Coverage
- 🔄 VPN Gateway deployment
- 🔄 ExpressRoute Gateway deployment
- 🔄 Azure Firewall integration
- 🔄 Network Virtual Appliances
- 🔄 Complex routing scenarios

## Best Practices

1. **Isolation**: Each test uses unique resource names to avoid conflicts
2. **Validation**: Tests include assertions to validate expected behavior
3. **Cleanup**: Tests are designed to clean up after themselves
4. **Documentation**: Each test includes clear descriptions of what it validates

## Contributing

When adding new tests:
1. Follow the existing naming convention
2. Include comprehensive assertions
3. Use unique resource names
4. Document the test purpose
5. Ensure tests are idempotent 