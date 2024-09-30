module "service_account" {
  for_each     = local.service_account_configs
  source       = "../modules/iam/service_account"
  project      = local.project
  name         = each.value.name
  display_name = try(each.value.display_name, null)
  description  = try(each.value.description, null)
}

module "project_iam_policy_members" {
  for_each = local.project_configs
  source   = "../modules/iam/members/project"

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

