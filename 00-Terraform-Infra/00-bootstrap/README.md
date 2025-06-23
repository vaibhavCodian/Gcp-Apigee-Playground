# 00-bootstrap

This folder contains Terraform code to bootstrap foundational Google Cloud Platform (GCP) infrastructure required for the Gcp-Apigee-Playground Proof of Concept.

## Purpose

The bootstrap step provisions shared resources that are prerequisites for subsequent modules, such as:

- **GCS Bucket**: For storing Terraform remote state.
- **GKE Cluster**: (Optional) For containerized workloads or future expansion.
- **Cloud Run Instances**: Deploys simple "Hello World" services for frontend and backend demonstration.

## Structure

- All resources are created in the target GCP project.
- Designed for modularity and reusability.
- Intended to be run before other infrastructure modules (e.g., Apigee provisioning).

## Usage

1. **Initialize Terraform:**
   ```sh
   terraform init
   ```

2. **Review and apply the plan:**
   ```sh
   terraform plan
   terraform apply
   ```

3. **Outputs:**
   - GCS bucket name for remote state.
   - GKE cluster details (if provisioned).
   - Cloud Run service URLs.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.3
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- GCP project with billing enabled and necessary permissions.

## Notes

- Update variables as needed for your environment.
- This folder should be applied before running Apigee or other infrastructure modules.

---
