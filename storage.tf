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
#   member = "principal://iam.googleapis.com/projects/52991355109/locations/global/workloadIdentityPools/lab-gke-se.svc.id.goog/subject/ns/default/sa/default"
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
