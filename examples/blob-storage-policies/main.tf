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
      location = "westeurope"
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 5.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
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
      storage = {
        role_definition_name = "Storage Account Backup Contributor"
        scope                = module.storage.account.id
      }
    }
    policies = local.policies
  }
}
