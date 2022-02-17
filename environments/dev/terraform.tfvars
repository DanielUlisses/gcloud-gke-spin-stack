project_id = dasilva-gke-spinn-stack
region     = "us-central1"
subnets = [
  {
    subnet_name   = "gke"
    subnet_ip     = "10.10.10.0/24"
    subnet_region = "us-central1"
    description   = "This subnet to be used by gke resources"
  },
  {
    subnet_name   = "internal"
    subnet_ip     = "10.10.20.0/24"
    subnet_region = "us-central1"
    description   = "This subnet to be restricted to be internal only"
  },
  {
    subnet_name   = "external"
    subnet_ip     = "10.10.30.0/24"
    subnet_region = "us-central1"
    description   = "This subnet to be used by external facing services"
  }
]
