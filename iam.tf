module "serviceaccount" {
  for_each = local.serviceaccount_configs
  source   = "github.com/lab-gke-se/modules//iam/service_account?ref=0.0.4"

  projectId = each.value.projectId
  # name        = each.value.name
  email       = try(each.value.email, null)
  description = try(each.value.description, null)
  displayName = try(each.value.displayName, null)
}

module "project_iam_policy_members" {
  for_each = local.project_configs
  source   = "github.com/lab-gke-se/modules//iam/members/project?ref=0.0.4"

  project   = each.value.projectId
  iamPolicy = each.value.iamPolicy
}

resource "google_project_iam_member" "logging_logWriter" {
  project = local.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:hpc-1-cloudbuild@lab-gke-se.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "artifactregistry_createOnPushWriter" {
  project = local.project
  role    = "roles/artifactregistry.createOnPushWriter"
  member  = "serviceAccount:hpc-1-cloudbuild@lab-gke-se.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "storage_objectAdmin" {
  project = local.project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:hpc-1-cloudbuild@lab-gke-se.iam.gserviceaccount.com"
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



moved {
  from = module.testapp_service_account.google_service_account.service_account
  to   = module.serviceaccount["testapp"].google_service_account.service_account
}

moved {
  from = module.keda_service_account.google_service_account.service_account
  to   = module.serviceaccount["sa-keda-operator"].google_service_account.service_account
}

# moved {
#   from = 
#   to = module.serviceaccount["sa-keda"].google_service_account.service_account
# }

moved {
  from = module.service_account["hpc-1-worker"].google_service_account.service_account
  to   = module.serviceaccount["hpc-1-worker"].google_service_account.service_account
}

moved {
  from = module.service_account["hpc-1-producer"].google_service_account.service_account
  to   = module.serviceaccount["hpc-1-producer"].google_service_account.service_account
}

moved {
  from = module.service_account["hpc-1-nodes"].google_service_account.service_account
  to   = module.serviceaccount["hpc-1-nodes"].google_service_account.service_account
}

moved {
  from = module.service_account["hpc-1-cloudbuild"].google_service_account.service_account
  to   = module.serviceaccount["hpc-1-cloudbuild"].google_service_account.service_account
}
