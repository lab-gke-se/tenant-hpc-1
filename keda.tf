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

resource "google_project_iam_member" "keda_iam_workloadIdentityUser" {
  project = local.project
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:sa-keda-operator@lab-gke-se.iam.gserviceaccount.com"
}

