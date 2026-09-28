module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.32"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "swedencentral"
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 6.0"

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    secrets = {
      random_string = {
        psql-admin-password = {
          length      = 16
          special     = false
          min_special = 0
          min_upper   = 2
        }
      }
    }
  }
}

module "postgresql" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 6.0"

  postgresql = {
    name                = module.naming.postgresql_flexible_server.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    administrator_login    = "psqladmin"
    administrator_password = module.kv.secrets.psql-admin-password.value
  }
}

module "backup_vault" {
  source  = "cloudnationhq/bvault/azure"
  version = "~> 3.0"

  vault = {
    name                = module.naming.data_protection_backup_vault.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    datastore_type      = "VaultStore"
    redundancy          = "LocallyRedundant"
    soft_delete         = "Off"

    identity = {
      type = "SystemAssigned"
    }

    role_assignments = {
      backup = {
        role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
        scope                = module.postgresql.server.id
      }
      reader = {
        role_definition_name = "Reader"
        scope                = module.rg.groups.demo.id
      }
    }

    policies = local.policies
  }
}
