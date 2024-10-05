module "queue" {
  for_each = local.pubsub_configs
  source   = "github.com/lab-gke-se/modules//pubsub?ref=0.0.4"

  project = local.project
  name    = each.value.name
}


# Add subscription for message pulling
