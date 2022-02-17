provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

locals {
  network_name     = "${var.project_id}-${var.environment}-vpc"
  gke_cluster_name = "${var.project_id}-${var.environment}-gke"
}

module "vpc" {
  source  = "terraform-google-modules/network/google//modules/vpc"
  version = "~> 4.1.0"

  project_id   = var.project_id
  network_name = local.network_name

  shared_vpc_host = false
}

module "vpc_snet" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 4.1.0"

  project_id   = var.project_id
  network_name = module.vpc.network_name

  subnets          = var.subnets
  secondary_ranges = var.subnets_secondary_ranges

}

module "iam" {
  source     = "./modules/iam"
  project_id = var.project_id
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version = "19.0.0"

  project_id                 = var.project_id
  name                       = local.gke_cluster_name
  regional                   = false
  zones                      = ["${var.region}-a"]
  network                    = module.vpc.network_name
  subnetwork                 = "gke"
  ip_range_pods              = "us-central1-01-gke-01-pods"
  ip_range_services          = "us-central1-01-gke-01-services"
  http_load_balancing        = false
  horizontal_pod_autoscaling = true
  network_policy             = false
  create_service_account     = false
  service_account            = module.iam.gke_service_account_email
  logging_service            = "logging.googleapis.com/kubernetes"
  monitoring_service         = "monitoring.googleapis.com/kubernetes"
  default_max_pods_per_node  = 30

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-1"
      node_locations     = "${var.region}-a"
      min_count          = 1
      max_count          = 6
      local_ssd_count    = 0
      disk_size_gb       = 20
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 3
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    default-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = var.tags

  depends_on = [
    module.vpc_snet
  ]
}
