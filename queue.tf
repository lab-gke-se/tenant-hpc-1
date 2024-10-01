module "queue" {
  for_each = local.pubsub_configs
  source   = "../modules/pubsub"

  project = local.project
  name    = each.value.name
}


# Add subscription for message pulling
