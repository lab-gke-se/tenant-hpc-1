Steps to install Keda and setup environment

gcloud container clusters list

# Set cluster and location
cluster_name=hpc-cluster-3
location=us-central1

# Check workloadPool is configure in the cluster
gcloud container clusters describe $cluster_name --location=$location --format="value(workloadIdentityConfig.workloadPool)"

# Get first nodepool
nodepool_name=$(gcloud container node-pools list --cluster=$cluster_name --location-$location --format="value(name)" | head -n1)

# Get nodepool 
gcloud container node-pools describe $nodepool_name --cluster=$cluster_name --location=$location --format="value(config.workloadMetadataConfig.mode)"

# oauth2

gcloud container clusters describe $cluster_name --location=$location | grep oauthScopes -A10 --color

# create GSA
GSA_PROJECT=$(gcloud config get project)
GSA_NAME=sa-keda
gcloud iam service-accounts create $GSA_NAME --project=$GSA_PROJECT

# add roles to GSA
ROLE_NAMES="roles/monitoring.viewer roles/logging.viewer roles/pubsub.viewer"
for ROLE_NAME in $ROLE_NAMES; do
  gcloud projects add-iam-policy-binding $GSA_PROJECT --member "serviceAccount:${GSA_NAME}@${GSA_PROJECT}.iam.gserviceaccount.com" --role "$ROLE_NAME"
done

# bind GSA to Kubernetes Service Account (KSA)
NAMESPACE=keda
KSA_NAME=keda-operator
gcloud iam service-accounts add-iam-policy-binding ${GSA_NAME}@${GSA_PROJECT}.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:${GSA_PROJECT}.svc.id.goog[$NAMESPACE/$KSA_NAME]"


Installing KEDA on GKE using Helm

# kubeconfig credentials
gcloud container clusters get-credentials $cluster_name --location=$location
kubectl get pods

# credentials for Helm
gcloud auth application-default login

# add KEDA repo
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

# deploy KEDA with annotation for KSA
# annotation ties KSA with GSA roles
helm install keda kedacore/keda --namespace keda --create-namespace --set serviceAccount.operator.annotations."iam\.gke\.io/gcp-service-account"="${GSA_NAME}@${GSA_PROJECT}.iam.gserviceaccount.com"

Validate KEDA installation
# shows KEDA version installed
helm list -n keda

# shows custom values used during installation, namely the KSA annotation
helm get values keda -n keda

# waits for deployments to be rolled out
kubectl rollout status deployment keda-operator -n keda --timeout=90s
kubectl rollout status deployment keda-operator-metrics-apiserver -n keda --timeout=90s

# check for success log message, try again if not yet found
kubectl logs -n keda deployment/keda-operator-metrics-apiserver | grep "has been successfully established"