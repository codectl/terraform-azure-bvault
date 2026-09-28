# Backup Vault

This terraform module simplifies the creation and management of azure data protection backup vaults, providing customizable options for backup policies, backup instances, and role-based access control, all managed through code.

## Features

Supports blob storage, disk, postgresql, and postgresql flexible server backup policies.

Enables backup instances with nested policy associations.

Utilization of terratest for robust validation.

Offers configurable retention rules and lifecycle management for backup policies.

Includes support for managed identity and role-based access control.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 5.0)

## Resources

The following resources are used by this module:

- [azurerm_data_protection_backup_instance_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage) (resource)
- [azurerm_data_protection_backup_instance_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk) (resource)
- [azurerm_data_protection_backup_instance_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql_flexible_server) (resource)
- [azurerm_data_protection_backup_policy_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage) (resource)
- [azurerm_data_protection_backup_policy_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk) (resource)
- [azurerm_data_protection_backup_policy_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_postgresql_flexible_server) (resource)
- [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_vault"></a> [vault](#input\_vault)

Description: n/a

Type:

```hcl
object({
    name                         = string
    resource_group_name          = optional(string)
    location                     = optional(string)
    tags                         = optional(map(string))
    cross_region_restore_enabled = optional(bool)
    datastore_type               = string
    immutability                 = optional(string)
    redundancy                   = string
    retention_duration_in_days   = optional(number)
    soft_delete                  = optional(string)
    identity = optional(object({
      identity_ids = optional(set(string))
      type         = string
    }))
    role_assignments = optional(map(object({
      role_definition_name                   = optional(string)
      role_definition_id                     = optional(string)
      scope                                  = optional(string)
      principal_id                           = optional(string)
      principal_type                         = optional(string)
      name                                   = optional(string)
      description                            = optional(string)
      condition                              = optional(string)
      condition_version                      = optional(string)
      delegated_managed_identity_resource_id = optional(string)
      skip_service_principal_aad_check       = optional(bool)
    })), {})
    policies = optional(object({
      blob_storage = optional(map(object({
        backup_repeating_time_intervals        = optional(list(string))
        name                                   = optional(string)
        operational_default_retention_duration = optional(string)
        time_zone                              = optional(string)
        vault_default_retention_duration       = optional(string)
        retention_rule = optional(map(object({
          name     = optional(string)
          priority = number
          criteria = object({
            absolute_criteria      = optional(string)
            days_of_month          = optional(set(number))
            days_of_week           = optional(set(string))
            months_of_year         = optional(set(string))
            scheduled_backup_times = optional(set(string))
            weeks_of_month         = optional(set(string))
          })
          life_cycle = object({
            data_store_type = string
            duration        = string
          })
        })), {})
        instances = optional(map(object({
          name                            = optional(string)
          storage_account_container_names = optional(list(string))
          storage_account_id              = string
        })), {})
      })), {})
      disks = optional(map(object({
        backup_repeating_time_intervals = list(string)
        default_retention_duration      = string
        name                            = optional(string)
        time_zone                       = optional(string)
        retention_rule = optional(map(object({
          duration = string
          name     = optional(string)
          priority = number
          criteria = object({
            absolute_criteria = optional(string)
          })
        })), {})
        instances = optional(map(object({
          disk_id                      = string
          name                         = optional(string)
          snapshot_resource_group_name = string
          snapshot_subscription_id     = optional(string)
        })), {})
      })), {})
      postgresql_flexible_servers = optional(map(object({
        backup_repeating_time_intervals = list(string)
        name                            = optional(string)
        time_zone                       = optional(string)
        default_retention_rule = object({
          life_cycle = map(object({
            data_store_type = string
            duration        = string
          }))
        })
        retention_rule = optional(map(object({
          name     = optional(string)
          priority = number
          criteria = object({
            absolute_criteria      = optional(string)
            days_of_week           = optional(set(string))
            months_of_year         = optional(set(string))
            scheduled_backup_times = optional(set(string))
            weeks_of_month         = optional(set(string))
          })
          life_cycle = map(object({
            data_store_type = string
            duration        = string
          }))
        })), {})
        instances = optional(map(object({
          server_id = string
          name      = optional(string)
        })), {})
      })), {})
    }), {})
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_data_protection_backup_vault"></a> [data\_protection\_backup\_vault](#output\_data\_protection\_backup\_vault)

Description: contains all exported attributes of the data protection backup vault

### <a name="output_instance_blob_storage"></a> [instance\_blob\_storage](#output\_instance\_blob\_storage)

Description: contains all exported attributes of the data protection backup instance blob storage

### <a name="output_instance_disks"></a> [instance\_disks](#output\_instance\_disks)

Description: contains all exported attributes of the data protection backup instance disk

### <a name="output_instance_postgresql_flexible_servers"></a> [instance\_postgresql\_flexible\_servers](#output\_instance\_postgresql\_flexible\_servers)

Description: contains all exported attributes of the data protection backup instance postgresql flexible server

### <a name="output_policy_blob_storage"></a> [policy\_blob\_storage](#output\_policy\_blob\_storage)

Description: contains all exported attributes of the data protection backup policy blob storage

### <a name="output_policy_disks"></a> [policy\_disks](#output\_policy\_disks)

Description: contains all exported attributes of the data protection backup policy disk

### <a name="output_policy_postgresql_flexible_servers"></a> [policy\_postgresql\_flexible\_servers](#output\_policy\_postgresql\_flexible\_servers)

Description: contains all exported attributes of the data protection backup policy postgresql flexible server
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md).

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/terraform-azure-bvault/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/backup/backup-vault-overview)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/dataprotection/)
