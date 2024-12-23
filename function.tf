locals {
  cloud_function = {
    producer = {
      service_account = "hpc-1-producer@lab-gke-se.iam.gserviceaccount.com"
    }
  }
}

data "archive_file" "cloud_function_source" {
  for_each    = local.cloud_function
  type        = "zip"
  source_dir  = abspath("${path.module}/src/${each.key}")
  output_path = "${path.module}/zip/${each.key}.zip"
}

resource "google_storage_bucket_object" "cloud_function_source" {
  for_each = local.cloud_function
  name     = format("%s_%s.%s", each.key, data.archive_file.cloud_function_source[each.key].output_md5, "zip")
  bucket   = module.storage["lab-gke-se-hpc-1-source"].name
  source   = data.archive_file.cloud_function_source[each.key].output_path
}

# Fix dependency issue with cloud function create ...
resource "google_project_iam_member" "reader" {
  for_each = local.cloud_function
  project  = local.project
  role     = "roles/artifactregistry.reader"
  member   = "serviceAccount:${each.value.service_account}"

  depends_on = [module.serviceaccount]
}

# Make this more specific to the storage bucket
resource "google_project_iam_member" "storage" {
  for_each = local.cloud_function
  project  = local.project
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${each.value.service_account}"

  depends_on = [module.serviceaccount]
}

resource "google_pubsub_topic_iam_member" "message" {
  for_each = local.cloud_function
  project  = local.project
  topic    = "hpc-1-messages"
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:${each.value.service_account}"

  depends_on = [module.serviceaccount]
}

moved {
  from = google_cloudfunctions_function.cloudfunction["producer"]
  to   = module.functions["hpc-1-producer"].google_cloudfunctions_function.function
}

module "functions" {
  source   = "github.com/lab-gke-se/modules//functions?ref=0.0.4"
  for_each = local.functions_configs

  project = local.project

  name                       = each.value.name
  description                = try(each.value.description, null)
  entryPoint                 = try(each.value.entryPoint, null)
  runtime                    = try(each.value.runtime, null)
  timeout                    = try(each.value.timeout, null)
  availableMemoryMb          = try(each.value.availableMemoryMb, null)
  serviceAccountEmail        = try(each.value.serviceAccountEmail, null)
  labels                     = try(each.value.labels, null)
  environmentVariables       = try(each.value.environmentVariables, null)
  buildEnvironmentVariables  = try(each.value.buildEnvironmentVariables, null)
  minInstances               = try(each.value.minInstances, null)
  maxInstances               = try(each.value.maxInstances, null)
  vpcConnector               = try(each.value.vpcConnector, null)
  vpcConnectorEgressSettings = try(each.value.vpcConnectorEgressSettings, null)
  ingressSettings            = try(each.value.ingressSettings)
  kmsKeyName                 = try(each.value.kmsKeyName, null)
  buildWorkerPool            = try(each.value.buildWorkerPool, null)
  secretEnvironmentVariables = try(each.value.secretEnvironmentVariables, null)
  secretVolumes              = try(each.value.secretVolumes, null)
  dockerRepository           = try(each.value.dockerRepository, null)
  dockerRegistry             = try(each.value.dockerRegistry, null)
  buildServiceAccount        = try(each.value.buildServiceAccount, null)
  sourceArchiveUrl           = "gs://${module.storage["lab-gke-se-hpc-1-source"].name}/${google_storage_bucket_object.cloud_function_source["producer"].name}"
  sourceRepository           = try(each.value.sourceRepository, null)
  sourceUploadUrl            = try(each.value.sourceUploadUrl, null)
  httpsTrigger               = try(each.value.httpsTrigger, null)
  eventTrigger               = try(each.value.eventTrigger, null)
}

# resource "google_cloudfunctions_function" "cloudfunction" {
#   for_each = local.cloud_function

#   project = local.project
#   region  = "us-central1"

#   name        = each.value.name
#   description = each.value.description
#   runtime     = each.value.runtime

#   service_account_email = each.value.service_account
#   build_service_account = each.value.build_service_account

#   available_memory_mb   = each.value.available_memory_mb
#   source_archive_bucket = each.value.source_archive_bucket
#   source_archive_object = google_storage_bucket_object.cloud_function_source[each.key].name

#   event_trigger {
#     event_type = each.value.event_trigger.event_type
#     resource   = each.value.event_trigger.resource
#   }

#   entry_point = each.value.entry_point

#   kms_key_name      = each.value.kms_key_id
#   docker_repository = each.value.docker_repository

#   ingress_settings              = each.value.ingress_settings
#   vpc_connector                 = each.value.vpc_connector
#   vpc_connector_egress_settings = each.value.vpc_connector_egress_settings

#   environment_variables = each.value.environment_variables

#   labels = each.value.labels
# }
