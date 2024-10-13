module "keda_service_account" {
  source = "github.com/lab-gke-se/modules//iam/service_account?ref=0.0.4"

  project      = local.project
  name         = "sa-keda-operator"
  display_name = "Keda operator service account"
  description  = "Service Account for Keda Operator"
}

resource "google_project_iam_member" "keda_monitoring_viewer" {
  project = local.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:sa-keda-operator@lab-gke-se.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "keda_iam_workloadIdentityUser" {
  service_account_id = module.keda_service_account.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:lab-gke-se.svc.id.goog[keda/keda-operator]"
}

module "testapp_service_account" {
  source = "github.com/lab-gke-se/modules//iam/service_account?ref=0.0.4"

  project      = local.project
  name         = "testapp"
  display_name = "Test App Keda Service Account"
  description  = "Test App"
}

resource "google_project_iam_member" "testapp_pubsub_subscriber" {
  project = local.project
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:testapp@lab-gke-se.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "testapp_iam_workloadIdentityUser" {
  service_account_id = module.testapp_service_account.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:lab-gke-se.svc.id.goog[default/testapp]"
}

