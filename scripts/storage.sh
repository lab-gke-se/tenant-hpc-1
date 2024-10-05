gcloud container clusters get-credentials hpc-1-standard-3 --location=us-central1
kubectl create namespace storage-test
kubectl create serviceaccount sa-storage --nanespace storage-test

gcloud storage buckets add-iam-policy-binding gs://lab-gke-se-hpc-1-storage \
    --member "principal://iam.googleapis.com/projects/52991355109/locations/global/workloadIdentityPools/lab-gke-se.svc.id.goog/subject/ns/storage-test/sa/sa-storage" \
    --role "roles/storage.admin"