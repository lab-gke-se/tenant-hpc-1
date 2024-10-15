locals {
  cloud_function = {
    producer = {
      name                  = "hpc-1-producer"
      description           = "Producer Cloud Function"
      service_account       = "hpc-1-producer@lab-gke-se.iam.gserviceaccount.com"
      build_service_account = "projects/lab-gke-se/serviceAccounts/hpc-1-cloudbuild@lab-gke-se.iam.gserviceaccount.com"
      available_memory_mb   = 256
      runtime               = "python311"
      event_trigger = {
        event_type = "google.pubsub.topic.publish"
        resource   = "hpc-1-controller"
      }
      entry_point                   = "event_handler"
      kms_key_id                    = local.substitutions.kms_key_usc1
      docker_repository             = "projects/lab-gke-se/locations/us-central1/repositories/hpc-1-images"
      ingress_settings              = "ALLOW_INTERNAL_ONLY"
      vpc_connector                 = null #var.vpc_connector
      vpc_connector_egress_settings = null # var.vpc_connector == null ? null : "ALL_TRAFFIC"
      source_archive_bucket         = module.storage["lab-gke-se-hpc-1-source"].name
      environment_variables : {}
      labels : {}
    }
    # worker = {
    #   name                  = "hpc-1-worker"
    #   description           = "Worker Cloud Function"
    #   service_account       = "hpc-1-worker@lab-gke-se.iam.gserviceaccount.com"
    #   build_service_account = "projects/lab-gke-se/serviceAccounts/hpc-1-cloudbuild@lab-gke-se.iam.gserviceaccount.com"
    #   available_memory_mb   = 256
    #   runtime               = "python311"
    #   event_trigger = {
    #     event_type = "google.pubsub.topic.publish"
    #     resource   = "hpc-1-messages"
    #   }
    #   entry_point                   = "event_handler"
    #   kms_key_id                    = local.substitutions.kms_key_usc1
    #   docker_repository             = "projects/lab-gke-se/locations/us-central1/repositories/hpc-1-images"
    #   ingress_settings              = "ALLOW_INTERNAL_ONLY"
    #   vpc_connector                 = null #var.vpc_connector
    #   vpc_connector_egress_settings = null # var.vpc_connector == null ? null : "ALL_TRAFFIC"
    #   source_archive_bucket         = module.storage_source.name
    #   environment_variables : {}
    #   labels : {}
    # }
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

  depends_on = [module.service_account]
}

# Make this more specific to the storage bucket
resource "google_project_iam_member" "storage" {
  for_each = local.cloud_function
  project  = local.project
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${each.value.service_account}"

  depends_on = [module.service_account]
}

resource "google_pubsub_topic_iam_member" "message" {
  for_each = local.cloud_function
  project  = local.project
  topic    = "hpc-1-messages"
  role     = "roles/pubsub.publisher"
  member   = "serviceAccount:${each.value.service_account}"

  depends_on = [module.service_account]
}

resource "google_cloudfunctions_function" "cloudfunction" {
  for_each = local.cloud_function

  project = local.project
  region  = "us-central1"

  name        = each.value.name
  description = each.value.description
  runtime     = each.value.runtime

  service_account_email = each.value.service_account
  build_service_account = each.value.build_service_account

  available_memory_mb   = each.value.available_memory_mb
  source_archive_bucket = each.value.source_archive_bucket
  source_archive_object = google_storage_bucket_object.cloud_function_source[each.key].name

  event_trigger {
    event_type = each.value.event_trigger.event_type
    resource   = each.value.event_trigger.resource
  }

  entry_point = each.value.entry_point

  kms_key_name      = each.value.kms_key_id
  docker_repository = each.value.docker_repository

  ingress_settings              = each.value.ingress_settings
  vpc_connector                 = each.value.vpc_connector
  vpc_connector_egress_settings = each.value.vpc_connector_egress_settings

  environment_variables = each.value.environment_variables

  labels = each.value.labels
}
