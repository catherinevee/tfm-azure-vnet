# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive Resource Map documentation in README
- Basic test infrastructure with native Terraform tests
- MIT License file for registry compliance
- CHANGELOG.md for version tracking
- Test documentation and examples

### Changed
- Updated Terraform version requirement to >= 1.13.0
- Updated Azure provider version to ~> 4.38.1
- Enhanced documentation with resource mapping
- Improved example configurations

### Fixed
- Version compatibility issues
- Documentation gaps for registry publishing
- Missing test infrastructure

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Azure VNet Terraform module
- Support for single and multi-VNet deployments
- Network Security Groups with customizable rules
- Route Tables with custom routing
- Site-to-Site VPN Gateway support
- ExpressRoute Gateway support
- Azure Firewall integration
- Network Virtual Appliances (NVAs) support
- Subnet delegations for Azure services
- Service endpoints configuration
- Comprehensive output variables
- Basic and advanced usage examples

### Features
- Hub-Spoke architecture support
- Public and private subnet configurations
- BGP community support
- DDoS protection plan integration
- Custom DNS server configuration
- Comprehensive tagging support
- Resource group creation or existing resource group usage

### Documentation
- Comprehensive README with usage examples
- Architecture diagrams
- Variable and output documentation
- Example configurations for common scenarios 