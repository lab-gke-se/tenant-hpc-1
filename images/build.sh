    gcloud builds submit ${path.module}/cloudbuild_builder/ \
      --project ${module.cloudbuild_project.project_id} \
      --config=${path.module}/cloudbuild_builder/cloudbuild.yaml \
      --substitutions=_GCLOUD_VERSION=${var.gcloud_version},_TERRAFORM_VERSION=${var.terraform_version},_TERRAFORM_VERSION_SHA256SUM=${var.terraform_version_sha256sum},_REGION=${google_artifact_registry_repository.tf-image-repo.location},_REPOSITORY=${local.gar_name}
