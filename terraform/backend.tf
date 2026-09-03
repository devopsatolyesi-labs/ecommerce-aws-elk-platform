# ==============================================================================
# AWS S3 State Backend (No DynamoDB Required)
# Uses Amazon S3 for state storage and native S3 lockfiles
# ==============================================================================

terraform {
  backend "s3" {
    # Configuration is supplied dynamically via CLI or GitHub Actions:
    #   terraform init \
    #     -backend-config="bucket=${S3_BUCKET_NAME}" \
    #     -backend-config="key=environments/${ENVIRONMENT}/terraform.tfstate" \
    #     -backend-config="region=${AWS_REGION}"
  }
}
