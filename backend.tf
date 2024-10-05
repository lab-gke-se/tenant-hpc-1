terraform {
  backend "gcs" {
    bucket = "lab-gke-se-tf-state"
    prefix = "terraform/tenant-hpc-1"
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "lab-gke-se-tf-state"
    prefix = "terraform/bootstrap"
  }
}

