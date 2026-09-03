# ==============================================================================
# Dynamic Multi-Environment Backend Configuration
# Usage:
#   terraform init -backend-config="bucket=my-tf-state-bucket" -backend-config="key=env/dev.tfstate" -backend-config="region=eu-west-1"
# ==============================================================================

terraform {
  # Backend is dynamically configured during 'terraform init -backend-config=...'
  # When running locally or during student labs without S3, can use default local backend.
}
