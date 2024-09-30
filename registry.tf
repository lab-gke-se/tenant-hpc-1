module "registry" {
  source   = "../modules/artifactregistry"
  for_each = local.artifactregistry_configs

  project                 = local.project
  name                    = each.value.name
  format                  = each.value.format
  description             = try(each.value.description, null)
  labels                  = try(each.value.labels, null)
  kmsKeyName              = try(each.value.kmsKeyName, null)
  mode                    = try(each.value.mode, null)
  cleanupPolicies         = try(each.value.cleanupPolices, null)
  cleanupPolicyDryRun     = try(each.value.cleanupPolicyDryRun, null)
  mavenConfig             = try(each.value.mavenConfig, null)
  dockerConfig            = try(each.value.dockerConfig, null)
  virtualRepositoryConfig = try(each.value.virtualRepositoryConfig, null)
  remoteRepositoryConfig  = try(each.value.remoteRepositoryConfig, null)
}
