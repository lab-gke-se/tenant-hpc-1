module "storage" {
  source   = "github.com/lab-gke-se/modules//storage/bucket?ref=0.0.4"
  for_each = local.storage_bucket_configs

  project = local.project

  name                        = each.value.name
  default_kms_key             = try(each.value.default_kms_key, null)
  public_access_prevention    = try(each.value.public_access_prevention, null)
  uniform_bucket_level_access = try(each.value.uniform_bucket_level_access, null)
  labels                      = try(each.value.labels, null)
  location                    = try(each.value.location, null)
  logging                     = try(each.value.logging, null)
  objectRetention             = try(each.value.objectRetention, null)
  retentionPolicy             = try(each.value.retentionPolicy, null)
  softDeletePolicy            = try(each.value.softDeletePolicy, null)
  default_storage_class       = try(each.value.default_storage_class, null)
  versioning_enabled          = try(each.value.versioning_enabled, null)
}

module "parallelstore" {
  source   = "github.com/lab-gke-se/modules//parallelstore?ref=0.0.4"
  for_each = local.parallelstore_configs

  name                 = each.value.name
  capacityGib          = each.value.capacityGib
  description          = try(each.value.description, null)
  network              = try(each.value.network, null)
  reservedIpRange      = try(each.value.reservedIpRange, null)
  fileStripeLevel      = try(each.value.fileStripeLevel, null)
  directoryStripeLevel = try(each.value.directoryStripeLevel, null)
  labels               = try(each.value.labels, null)
}
