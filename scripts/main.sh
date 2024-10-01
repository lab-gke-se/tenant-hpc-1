export PROJECT=lab-gke-se
export NETWORK_NAME=hpc-1
export IP_RANGE_NAME=parallelstore-range 
export INSTANCE_ID=prallelstore1
export FIREWALL_RULE_NAME=parrallelstore-fw-rule
export PROJECT=lab-gke-se

    
gcloud services enable parallelstore.googleapis.com --project=${PROJECT}
gcloud services enable servicenetworking.googleapis.com --project=${PROJECT}

gcloud compute networks create $NETWORK_NAME --subnet-mode=auto --project=${PROJECT} --mtu=8996

gcloud compute addresses create hpc-1-parallelstore-1 \
--global \
--purpose=VPC_PEERING \
--prefix-length=24 \
--description="Parallelstore VPC Peering" \
--network="hpc-1" \
--project="lab-gke-se"

CIDR_RANGE=$(
    gcloud compute address describe $IP_RANGE_NAME \
    --global \
    --format="value[separator=/](address, prefixLength)" \
    --project=${PROJECT}
)

gcloud compute firewall-rules create hpc-1-allow-parallelstore-1 --allow=tcp --source-ranges=10.19.136.0/24 --network=hpc-1 --project=lab-gke-se

gcloud services vpc-peerings connect --network=hpc-1 --project=lab-gke-se --ranges=hpc-1-parallelstore-1 --service=servicenetworking.googleapis.com

gcloud container clusters create hpc-1-standard-4 --location=us-central1-a --network=hpc-1 --addons=ParallelstoreCsiDriver --cluster-version=1.29 --release-ch
annel rapid

gcloud alpha parallelstore instances create hpc-1-storage --capacity-gib=16000 --location=us-central1-a --network=hpc-1 --project=lab-gke-se





gcloud container clusters update hpc-1-standard-3 --location=us-central1-a --update-addons=ParallelstoreCsiDriver=ENABLED