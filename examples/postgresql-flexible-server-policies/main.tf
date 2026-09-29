module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "swedencentral"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "kv" {
  source  = "codectl/kv/azure"
  version = "~> 1.0"

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
  source  = "codectl/psql/azure"
  version = "~> 1.0"

  postgresql = {
    name                = module.naming.postgresql_flexible_server.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    administrator_login    = "psqladmin"
    administrator_password = module.kv.secrets.psql-admin-password.value
  }
}

module "backup_vault" {
  source  = "codectl/bvault/azure"
  version = "~> 1.0"

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
