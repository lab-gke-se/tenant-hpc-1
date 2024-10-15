module "storage_east4" {
  source = "github.com/lab-gke-se/modules//storage/bucket?ref=0.0.4"

  project             = local.project
  name                = "hpc-1-bucket-1"
  location            = "us-east4"
  data_classification = "data"
  kms_key_id          = local.substitutions.kms_key
}

module "storage" {
  source = "github.com/lab-gke-se/modules//storage/bucket?ref=0.0.4"

  project             = local.project
  name                = "hpc-1-bucket-3"
  location            = "us-central1"
  data_classification = "data"
  kms_key_id          = local.substitutions.kms_key_usc1
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

module "storage_source" {
  source = "github.com/lab-gke-se/modules//storage/bucket?ref=0.0.4"

  project             = local.project
  name                = "hpc-1-source"
  location            = "us-central1"
  data_classification = "source"
  kms_key_id          = local.substitutions.kms_key_usc1
}

# resource "google_storage_bucket_iam_member" "testapp_storage_admin" {
#   bucket = module.storage.name
#   role   = "roles/storage.admin"
#   member = "principal://iam.googleapis.com/projects/52991355109/locations/global/workloadIdentityPools/lab-gke-se.svc.id.goog/subject/ns/default/sa/pass"
# }


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

