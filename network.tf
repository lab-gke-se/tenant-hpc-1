# Moved to development so don't keep recreating

# module "network" {
#   for_each = local.network_configs
#   source   = "github.com/lab-gke-se/modules//network/vpc?ref=0.0.3"

#   project               = local.project
#   shared_vpc_host       = false
#   delete_default_routes = true

#   name                                  = each.value.name
#   description                           = try(each.value.description, null)
#   routingConfig                         = try(each.value.routingConfig, null)
#   autoCreateSubnetworks                 = try(each.value.autoCreateSubnetworks, null)
#   mtu                                   = try(each.value.mtu, null)
#   enableUlaInternalIpv6                 = try(each.value.enableUlaInternalIpv6, null)
#   internalIpv6Range                     = try(each.value.internalIpv6Range, null)
#   networkFirewallPolicyEnforcementOrder = try(each.value.networkFirewallPolicyEnforcementOrder, null)
# }

# module "subnetwork" {
#   for_each = local.subnetwork_configs
#   source   = "github.com/lab-gke-se/modules//network/subnetwork?ref=0.0.3"

#   project                 = local.project
#   network                 = each.value.network
#   name                    = each.value.name
#   ipCidrRange             = try(each.value.ipCidrRange, null)
#   region                  = try(each.value.region, null)
#   privateIpGoogleAccess   = try(each.value.privateIpGoogleAccess, null)
#   privateIpv6GoogleAccess = try(each.value.privateIpv6GoogleAccess, null)
#   purpose                 = try(each.value.purpose, null)
#   role                    = try(each.value.role, null)
#   stackType               = try(each.value.stackType, null)
#   ipv6AccessType          = try(each.value.ipv6AccessType, null)
#   externalIpv6Prefix      = try(each.value.externalIpv6Prefix, null)
#   secondaryIpRanges       = try(each.value.secondaryIpRanges, null)
#   logConfig               = try(each.value.logConfig, null)

#   depends_on = [module.network]
# }
