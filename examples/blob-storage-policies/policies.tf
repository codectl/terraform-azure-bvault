locals {
  policies = {
    blob_storage = {
      daily = {
        operational_default_retention_duration = "P30D"

        instances = {
          sa1 = {
            storage_account_id = module.storage.account.id
          }
        }
      }
    }
  }
}
