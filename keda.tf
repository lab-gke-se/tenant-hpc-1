# module "keda_service_account" {
#   source = "github.com/lab-gke-se/modules//iam/service_account?ref=0.0.4"

#   project = local.serviceaccount_configs["sa-keda-operator"].project
#   name    = local.serviceaccount_configs["sa-keda-operator"].project
#   # dispalyName      = local.serviceaccount_configs["sa-keda"].project
#   description = local.serviceaccount_configs["sa-keda-operator"].project
# }

resource "google_project_iam_member" "keda_monitoring_viewer" {
  project = local.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:sa-keda-operator@lab-gke-se.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "keda_iam_workloadIdentityUser" {
  service_account_id = module.serviceaccount["sa-keda-operator"].id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:lab-gke-se.svc.id.goog[keda/keda-operator]"
}

# module "testapp_service_account" {
#   source = "github.com/lab-gke-se/modules//iam/service_account?ref=0.0.4"

#   project = local.serviceaccount_configs["testapp"].project
#   name    = local.serviceaccount_configs["testapp"].project
#   # dispalyName      = local.serviceaccount_configs["sa-keda"].project
#   description = local.serviceaccount_configs["testapp"].project
# }

resource "google_project_iam_member" "testapp_pubsub_subscriber" {
  project = local.project
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:testapp@lab-gke-se.iam.gserviceaccount.com"
}

resource "google_service_account_iam_member" "testapp_iam_workloadIdentityUser" {
  service_account_id = module.serviceaccount["testapp"].id
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:lab-gke-se.svc.id.goog[default/testapp]"
}

