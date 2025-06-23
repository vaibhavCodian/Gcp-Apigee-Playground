// GCS Bucket module
// Expects a map of objects for multiple bucket creation

variable "buckets" {
  description = "Map of GCS bucket objects."
  type        = map(object({
    name          = string
    location      = string
    storage_class = string
    force_destroy = bool
  }))
}

resource "google_storage_bucket" "buckets" {
  for_each      = var.buckets
  name          = each.value.name
  location      = each.value.location
  storage_class = each.value.storage_class
  force_destroy = each.value.force_destroy
}

output "bucket_names" {
  value = [for b in google_storage_bucket.buckets : b.name]
}
