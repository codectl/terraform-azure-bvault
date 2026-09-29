module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
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

module "storage" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
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
      storage = {
        role_definition_name = "Storage Account Backup Contributor"
        scope                = module.storage.account.id
      }
    }
    policies = local.policies
  }
}
