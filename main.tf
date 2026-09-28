data "azurerm_client_config" "this" {}

resource "azurerm_data_protection_backup_vault" "this" {
  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.vault.location, var.location
  )

  tags = coalesce(
    var.vault.tags, var.tags
  )

  cross_region_restore_enabled = var.vault.cross_region_restore_enabled
  datastore_type               = var.vault.datastore_type
  immutability                 = var.vault.immutability
  name                         = var.vault.name
  redundancy                   = var.vault.redundancy
  retention_duration_in_days   = var.vault.retention_duration_in_days
  soft_delete                  = var.vault.soft_delete

  dynamic "identity" {
    for_each = var.vault.identity != null ? { "this" = var.vault.identity } : {}

    content {
      identity_ids = identity.value.identity_ids
      type         = identity.value.type
    }
  }
}

resource "azurerm_data_protection_backup_policy_blob_storage" "this" {
  for_each = var.vault.policies.blob_storage

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                               = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals        = each.value.backup_repeating_time_intervals
  operational_default_retention_duration = each.value.operational_default_retention_duration
  time_zone                              = each.value.time_zone
  vault_default_retention_duration       = each.value.vault_default_retention_duration

  dynamic "retention_rule" {
    for_each = each.value.retention_rule

    content {
      priority = retention_rule.value.priority
      name = coalesce(
        retention_rule.value.name, retention_rule.key
      )

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? { "this" = retention_rule.value.criteria } : {}

        content {
          absolute_criteria      = criteria.value.absolute_criteria
          days_of_month          = criteria.value.days_of_month
          days_of_week           = criteria.value.days_of_week
          months_of_year         = criteria.value.months_of_year
          scheduled_backup_times = criteria.value.scheduled_backup_times
          weeks_of_month         = criteria.value.weeks_of_month
        }
      }

      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle != null ? { "this" = retention_rule.value.life_cycle } : {}

        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_blob_storage" "this" {
  for_each = merge([
    for policy_key, policy in var.vault.policies.blob_storage : {
      for instance_key, instance in policy.instances :
      "${policy_key}.${instance_key}" => merge(instance, { policy_key = policy_key, instance_key = instance_key })
    }
  ]...)

  name = coalesce(
    each.value.name, each.value.instance_key
  )

  backup_policy_id                = azurerm_data_protection_backup_policy_blob_storage.this[each.value.policy_key].id
  vault_id                        = azurerm_data_protection_backup_vault.this.id
  location                        = azurerm_data_protection_backup_vault.this.location
  storage_account_container_names = each.value.storage_account_container_names
  storage_account_id              = each.value.storage_account_id

  depends_on = [azurerm_role_assignment.this]
}

resource "azurerm_data_protection_backup_policy_disk" "this" {
  for_each = var.vault.policies.disks

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                        = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  default_retention_duration      = each.value.default_retention_duration
  time_zone                       = each.value.time_zone

  dynamic "retention_rule" {
    for_each = each.value.retention_rule

    content {
      duration = retention_rule.value.duration
      priority = retention_rule.value.priority
      name = coalesce(
        retention_rule.value.name, retention_rule.key
      )

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? { "this" = retention_rule.value.criteria } : {}

        content {
          absolute_criteria = criteria.value.absolute_criteria
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_disk" "this" {
  for_each = merge([
    for policy_key, policy in var.vault.policies.disks : {
      for instance_key, instance in policy.instances :
      "${policy_key}.${instance_key}" => merge(instance, { policy_key = policy_key, instance_key = instance_key })
    }
  ]...)

  name = coalesce(
    each.value.name, each.value.instance_key
  )

  backup_policy_id             = azurerm_data_protection_backup_policy_disk.this[each.value.policy_key].id
  disk_id                      = each.value.disk_id
  vault_id                     = azurerm_data_protection_backup_vault.this.id
  location                     = azurerm_data_protection_backup_vault.this.location
  snapshot_resource_group_name = each.value.snapshot_resource_group_name
  snapshot_subscription_id     = each.value.snapshot_subscription_id

  depends_on = [azurerm_role_assignment.this]
}

resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "this" {
  for_each = var.vault.policies.postgresql_flexible_servers

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                        = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  time_zone                       = each.value.time_zone

  dynamic "default_retention_rule" {
    for_each = each.value.default_retention_rule != null ? { "this" = each.value.default_retention_rule } : {}

    content {
      dynamic "life_cycle" {
        for_each = default_retention_rule.value.life_cycle

        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }

  dynamic "retention_rule" {
    for_each = each.value.retention_rule

    content {
      name = coalesce(
        retention_rule.value.name, retention_rule.key
      )

      priority = retention_rule.value.priority

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? { "this" = retention_rule.value.criteria } : {}

        content {
          absolute_criteria      = criteria.value.absolute_criteria
          days_of_week           = criteria.value.days_of_week
          months_of_year         = criteria.value.months_of_year
          scheduled_backup_times = criteria.value.scheduled_backup_times
          weeks_of_month         = criteria.value.weeks_of_month
        }
      }

      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle

        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "this" {
  for_each = merge([
    for policy_key, policy in var.vault.policies.postgresql_flexible_servers : {
      for instance_key, instance in policy.instances :
      "${policy_key}.${instance_key}" => merge(instance, { policy_key = policy_key, instance_key = instance_key })
    }
  ]...)

  name = coalesce(
    each.value.name, each.value.instance_key
  )

  backup_policy_id = azurerm_data_protection_backup_policy_postgresql_flexible_server.this[each.value.policy_key].id
  server_id        = each.value.server_id
  vault_id         = azurerm_data_protection_backup_vault.this.id
  location         = azurerm_data_protection_backup_vault.this.location

  depends_on = [azurerm_role_assignment.this]
}

resource "azurerm_role_assignment" "this" {
  for_each = var.vault.role_assignments

  scope = coalesce(
    each.value.scope, azurerm_data_protection_backup_vault.this.id
  )

  principal_id = coalesce(
    each.value.principal_id, try(azurerm_data_protection_backup_vault.this.identity[0].principal_id, data.azurerm_client_config.this.object_id)
  )

  role_definition_name                   = each.value.role_definition_name
  role_definition_id                     = each.value.role_definition_id
  principal_type                         = each.value.principal_type
  name                                   = each.value.name
  description                            = each.value.description
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
