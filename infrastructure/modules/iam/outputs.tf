output "gke_service_account_email" {
  value = google_service_account.gke_service_account.email
}

output "gke_service_account_credentials" {
  value     = google_service_account_key.gke_service_account.private_key
  sensitive = true
}
