terraform {
  backend "gcs" {
    bucket = "dasilva-gke-spinn-stack-tfstate"
    prefix = "env/prod"
  }
}
