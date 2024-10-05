# Moved to bootstrap so don't keep recreating

# module "kms_keyring" {
#   source = "../modules/kms/key_ring"

#   name     = "hpc-1"
#   project  = local.project
#   location = local.location
# }

# module "kms_key" {
#   source = "../modules/kms/key"

#   name     = "hpc-1"
#   project  = local.project
#   key_ring = module.kms_keyring.id
#   services = local.services

#   depends_on = [module.kms_keyring]
# }
