variable "vault" {
  type = object({
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

  validation {
    condition     = var.vault.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.vault.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the config object or as a separate variable."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
