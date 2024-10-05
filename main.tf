locals {

  project                  = "lab-gke-se"
  location                 = "us-east4"
  deletion_protection      = false
  remove_default_node_pool = true

  services = [
    "artifactregistry.googleapis.com",
    "cloudfunctions.googleapis.com",
    "container.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "secretmanager.googleapis.com"
  ]

  substitutions = {
    kms_key         = "projects/lab-gke-se/locations/us-east4/keyRings/hpc-1-8uhu/cryptoKeys/hpc-1"
    kms_key_usc1    = "projects/lab-gke-se/locations/us-central1/keyRings/hpc-1-us-central1-kza4/cryptoKeys/hpc-1-us-central1"
    service_account = try(module.service_account["hpc-1-nodes"].email, null)
  }

  # network_files          = fileset("${path.module}/config/compute/network", "*.yaml")
  # subnetwork_files       = fileset("${path.module}/config/compute/subnetwork", "*.yaml")
  firewall_files         = fileset("${path.module}/config/compute/firewall", "*.yaml")
  secret_files           = fileset("${path.module}/config/secretmanager/secret", "*.yaml")
  artifactregistry_files = fileset("${path.module}/config/artifactregistry", "*.yaml")
  pubsub_files           = fileset("${path.module}/config/pubsub", "*.yaml")
  service_account_files  = fileset("${path.module}/config/iam/service_account", "*.yaml")
  project_files          = fileset("${path.module}/config/iam/project", "*.yaml")
  cluster_files          = fileset("${path.module}/config/container/cluster", "*.yaml")

  # network_configs          = { for filename in local.network_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/compute/network/${filename}", local.substitutions)) }
  # subnetwork_configs       = { for filename in local.subnetwork_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/compute/subnetwork/${filename}", local.substitutions)) }
  firewall_configs         = { for filename in local.firewall_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/compute/firewall/${filename}", local.substitutions)) }
  secret_configs           = { for filename in local.secret_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/secretmanager/secret/${filename}", local.substitutions)) }
  artifactregistry_configs = { for filename in local.artifactregistry_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/artifactregistry/${filename}", local.substitutions)) }
  pubsub_configs           = { for filename in local.pubsub_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/pubsub/${filename}", local.substitutions)) }
  service_account_configs  = { for filename in local.service_account_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/iam/service_account/${filename}", {})) }
  project_configs          = { for filename in local.project_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/iam/project/${filename}", {})) }
  cluster_configs          = { for filename in local.cluster_files : replace(filename, ".yaml", "") => yamldecode(templatefile("${path.module}/config/container/cluster/${filename}", local.substitutions)) }
}
