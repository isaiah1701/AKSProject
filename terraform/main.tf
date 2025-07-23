module "rg" {
  source   = "./modules/resource_group"
  name     = var.resource_group_name
  location = var.location
}

module "vnet" {
  source                = "./modules/vnet"
  vnet_name             = "vnet01"
  address_space         = ["10.0.0.0/16"]
  location              = module.rg.location
  resource_group_name   = module.rg.name
  private_subnet_name   = "private-subnet"
  private_subnet_prefix = ["10.0.1.0/24"]
  public_subnet_name    = "public-subnet"
  public_subnet_prefix  = ["10.0.2.0/24"]
}

module "aks" {
  source              = "./modules/aks"
  cluster_name        = "aks-cluster"
  dns_prefix          = "aks"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.vnet.private_subnet_id
}

module "storage" {
  source              = "./modules/storage"
    storage_account_name = module.rg.name
  location            = module.rg.location
  resource_group_name = module.rg.name
}

module "dns" {
  source              = "./modules/dns"
  domain              = var.domain_name
  resource_group_name = module.rg.name
}
