# gcloud builds submit ${path.module}/cloudbuild_builder/ \
#   --project ${module.cloudbuild_project.project_id} \
#   --config=${path.module}/cloudbuild_builder/cloudbuild.yaml \
#   --substitutions=_GCLOUD_VERSION=${var.gcloud_version},_TERRAFORM_VERSION=${var.terraform_version},_TERRAFORM_VERSION_SHA256SUM=${var.terraform_version_sha256sum},_REGION=${google_artifact_registry_repository.tf-image-repo.location},_REPOSITORY=${local.gar_name}

# docker build -t worker --platform linux/amd64 .

docker build -t us-central1-docker.pkg.dev/lab-gke-se/hpc-1-images/hpc-1-worker-k8 --platform linux/amd64 . 
docker push us-central1-docker.pkg.dev/lab-gke-se/hpc-1-images/hpc-1-worker-k8:<version>