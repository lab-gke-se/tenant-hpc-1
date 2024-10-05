module "storage" {
  source = "github.com/lab-gke-se/modules//storage/bucket?ref=0.0.4"

  project             = local.project
  name                = "hpc-1-storage"
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
