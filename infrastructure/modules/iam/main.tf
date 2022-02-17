# gke service account and credentials
resource "google_service_account" "gke_service_account" {
  account_id   = "gke"
  display_name = "gke Service Account"
}

resource "google_service_account_key" "gke_service_account" {
  service_account_id = google_service_account.gke_service_account.name
}


# grant access to all GKE clusters

resource "google_project_iam_member" "kubernetes_engine_admin" {
  project = var.project_id

  role   = "roles/container.admin"
  member = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# access to Container Registry project

resource "google_project_iam_member" "container_registry_object_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}


resource "google_project_iam_member" "docker_registry_project_browser" {
  project = var.project_id
  role    = "roles/browser"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# access to GCS artifacts

resource "google_project_iam_member" "gcs_artifacts_storage_admin" {
  project = var.project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}

# run cloudbuild builds
resource "google_project_iam_member" "cloudbuild" {
  project = var.project_id
  role    = "roles/cloudbuild.builds.builder"
  member  = "serviceAccount:${google_service_account.gke_service_account.email}"
}
