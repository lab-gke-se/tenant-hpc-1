module "cluster" {
  for_each = local.cluster_configs
  # source   = "github.com/lab-gke-se/modules//gke/cluster?ref=0.0.3"
  source = "../modules//gke/cluster"

  # Terraform variables
  project                  = local.project
  deletion_protection      = false
  remove_default_node_pool = false

  # GKE Variables
  name                           = each.value.name
  addonsConfig                   = try(each.value.addonsConfig, null)
  authenticatorGroupsConfig      = try(each.value.authenticatorGroupsConfig, null)
  autopilot                      = try(each.value.autopilot, null)
  autoscaling                    = try(each.value.autoscaling, null)
  binaryAuthorization            = try(each.value.binaryAuthorization, null)
  clusterIpv4Cidr                = try(each.value.clusterIpv4Cidr, null)
  confidentialNodes              = try(each.value.confidentialNodes, null)
  costManagementConfig           = try(each.value.costManagementConfig, null)
  currentMasterVersion           = try(each.value.currentMasterVersion, null)
  currentNodeVersion             = try(each.value.currentNodeVersion, null)
  databaseEncryption             = try(each.value.databaseEncryption, null)
  defaultMaxPodsConstraint       = try(each.value.defaultMaxPodsConstraint, null)
  description                    = try(each.value.description, null)
  enableKubernetesAlpha          = try(each.value.enableKubernetesAlpha, null)
  enableK8sBetaApis              = try(each.value.enableK8sBetaApis, null)
  enableTpu                      = try(each.value.enableTpu, null)
  fleet                          = try(each.value.fleet, null)
  identityServiceConfig          = try(each.value.identityServiceConfig, null)
  initialClusterVersion          = try(each.value.initialClusterVersion, null)
  initialNodeCount               = try(each.value.initialNodeCount, null)
  ipAllocationPolicy             = try(each.value.ipAllocationPolicy, null)
  legacyAbac                     = try(each.value.legacyAbac, null)
  location                       = try(each.value.location, null)
  locations                      = try(each.value.locations, null)
  loggingConfig                  = try(each.value.loggingConfig, null)
  loggingService                 = try(each.value.loggingService, null)
  maintenancePolicy              = try(each.value.maintenancePolicy, null)
  masterAuth                     = try(each.value.masterAuth, null)
  masterAuthorizedNetworksConfig = try(each.value.masterAuthorizedNetworksConfig, null)
  meshCertificates               = try(each.value.meshCertificates, null)
  monitoringConfig               = try(each.value.monitoringConfig, null)
  monitoringService              = try(each.value.monitoringService, null)
  network                        = try(each.value.network, null)
  networkConfig                  = try(each.value.networkConfig, null)
  networkPolicy                  = try(each.value.networkPolicy, null)
  nodeConfig                     = try(each.value.nodeConfig, null)
  nodePools                      = try(each.value.nodePools, null)
  nodePoolAutoConfig             = try(each.value.nodePoolAutoConfig, null)
  nodePoolDefaults               = try(each.value.nodePoolDefaults, null)
  notificationConfig             = try(each.value.notificationConfig, null)
  privateClusterConfig           = try(each.value.privateClusterConfig, null)
  releaseChannel                 = try(each.value.releaseChannel, null)
  resourceLabels                 = try(each.value.resourceLabels, null)
  resourceUsageExportConfig      = try(each.value.resourceUsageExportConfig, null)
  securityPostureConfig          = try(each.value.securityPostureConfig, null)
  shieldedNodes                  = try(each.value.shieldedNodes, null)
  subnetwork                     = try(each.value.subnetwork, null)
  verticalPodAutoscaling         = try(each.value.verticalPodAutoscaling, null)
  workloadIdentityConfig         = try(each.value.workloadIdentityConfig, null)

  depends_on = [module.project_iam_policy_members]
}

module "node_pools" {
  for_each = local.cluster_configs
  # source   = "github.com/lab-gke-se/modules//gke/node_pools?ref=0.0.3"
  source = "../modules/gke/node_pools"

  # Terraform / cluster variables
  project   = local.project
  cluster   = module.cluster[each.key].id
  location  = each.value.location
  nodePools = try(each.value.nodePools, null)
}
