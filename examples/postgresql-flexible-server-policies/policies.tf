locals {
  policies = {
    postgresql_flexible_servers = {
      weekly = {
        backup_repeating_time_intervals = ["R/2024-01-01T02:00:00+00:00/P1W"]
        time_zone                       = "UTC"

        default_retention_rule = {
          life_cycle = {
            default = {
              data_store_type = "VaultStore"
              duration        = "P30D"
            }
          }
        }

        instances = {
          psql1 = {
            server_id = module.postgresql.server.id
          }
        }
      }
    }
  }
}
