# Gcp-Apigee-Playground

A Proof of Concept (PoC) for demonstrating Google Cloud Apigee API Management with Cloud Run and GKE backend services.

## Features
- Deploys frontend and backend demo services to Cloud Run (and optionally GKE)
- Provisions all infrastructure using Terraform
- Exposes Cloud Run services via Apigee API Proxies
- Demonstrates API management features:
  - Rate limiting
  - OAuth and Auth token validation
  - Preflow and Postflow policies
- Modular, scalable folder structure for easy expansion

## Structure
- `00-Terraform-Infra/` : Infrastructure as Code for GCP, Apigee, Cloud Run, GKE, etc.
- `01-Demo-Services/`   : Source code for demo frontend and backend services
- `apigee-config/`      : Apigee API proxy definitions and policies
- `cloud-run-deployment/` : Cloud Run deployment scripts and manifests
- `gke-deployment/`     : (Optional) GKE deployment manifests
- `Local-Context.md`    : Project context and design notes

## Getting Started
1. Bootstrap infrastructure with Terraform
2. Build and deploy demo services to Cloud Run
3. Deploy Apigee API proxies
4. Test API management features

See individual folder READMEs for details.
