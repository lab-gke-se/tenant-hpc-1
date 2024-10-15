moved {
  from = module.storage.google_storage_bucket.bucket
  to   = module.storage["lab-gke-se-hpc-1-bucket-3"].google_storage_bucket.bucket
}

moved {
  from = module.storage_east4.google_storage_bucket.bucket
  to   = module.storage["lab-gke-se-hpc-1-bucket-1"].google_storage_bucket.bucket
}

moved {
  from = module.storage_source.google_storage_bucket.bucket
  to   = module.storage["lab-gke-se-hpc-1-source"].google_storage_bucket.bucket
}


module "storage" {
  source   = "github.com/lab-gke-se/modules//storage/bucket?ref=0.0.4"
  for_each = local.storage_bucket_configs

  project          = local.project
  name             = each.value.name
  encryption       = try(each.value.encryption, null)
  iamConfiguration = try(each.value.iamConfiguration, null)
  labels           = try(each.value.labels, null)
  location         = try(each.value.location, null)
  logging          = try(each.value.logging, null)
  objectRetention  = try(each.value.objectRetention, null)
  retentionPolicy  = try(each.value.retentionPolicy, null)
  softDeletePolicy = try(each.value.softDeletePolicy, null)
  storageClass     = try(each.value.storageClass, null)
  versioning       = try(each.value.versioning, null)
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

resource "google_project_service_identity" "parallelstore" {
  provider = google-beta

  project = local.project
  service = "parallelstore.googleapis.com"
}

resource "google_project_iam_member" "parallel_storage_admin" {
  project = local.project
  role    = "roles/storage.admin"
  member  = google_project_service_identity.parallelstore.member
}

resource "google_project_iam_member" "default_storage_admin" {
  project = local.project
  role    = "roles/storage.admin"
  member  = "principal://iam.googleapis.com/projects/52991355109/locations/global/workloadIdentityPools/lab-gke-se.svc.id.goog/subject/ns/default/sa/default"
}

resource "google_project_iam_member" "node_storage_admin" {
  project = local.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:hpc-1-nodes@lab-gke-se.iam.gserviceaccount.com"
}

