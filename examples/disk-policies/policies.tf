locals {
  policies = {
    disks = {
      daily = {
        backup_repeating_time_intervals = ["R/2024-01-01T02:00:00+00:00/PT4H"]
        default_retention_duration      = "P7D"
        time_zone                       = "UTC"

        retention_rule = {
          weekly = {
            duration = "P7D"
            priority = 25
            criteria = {
              absolute_criteria = "FirstOfWeek"
            }
          }
        }

        instances = {
          data = {
            disk_id                      = module.vm.disks.data.id
            snapshot_resource_group_name = module.rg.groups.demo.name
          }
        }
      }
    }
  }
}
