module "secret" {
  source   = "github.com/lab-gke-se/modules//secretmanager/secret?ref=0.0.4"
  for_each = local.secret_configs

  project        = local.project
  name           = each.value.name
  replication    = try(each.value.replication, null)
  labels         = try(each.value.labels, null)
  topics         = try(each.value.topics, null)
  rotation       = try(each.value.rotation, null)
  versionAliases = try(each.value.versionAliases, null)
  annotations    = try(each.value.annotations, null)
  expireTime     = try(each.value.expireTime, null)
  ttl            = try(each.value.ttl, null)
}

# module "secret_data_certificate" {
#   source = "../modules/secretmanager/version"

#   secret     = try(module.secret["hpc-1-certificates"].id, null)
#   secretData = "example.com"
# }
