module "firewall_rules" {
  source   = "github.com/lab-gke-se/modules//compute/firewall/rule?ref=0.0.4"
  for_each = local.firewall_configs

  project           = local.project
  name              = each.value.name
  network           = each.value.network
  disabled          = try(each.value.disabled, null)
  direction         = try(each.value.direction, null)
  priority          = try(each.value.priority, null)
  allowed           = try(each.value.allowed, null)
  sourceRanges      = try(each.value.sourceRanges, null)
  destinationRanges = try(each.value.destinationRanges, null)
  logConfig         = try(each.value.logConfig, null)

}

