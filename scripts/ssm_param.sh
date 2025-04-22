#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Ensure pipeline errors are caught

if ! aws sts get-caller-identity > /dev/null 2>&1; then
  echo "Error: Unable to authenticate. Please ensure AWS SSO is logged in or credentials are configured correctly." >&2
  exit 1
fi

# Fetch parameters from SSM
export AWS_REGION=us-east-1
bucket=$(aws ssm get-parameter --name "/terraform-backend/states-bucket-name" --query "Parameter.Value" --output text)
region=$(aws ssm get-parameter --name "/terraform-backend/states-bucket-region" --query "Parameter.Value" --output text)
dynamodb_table=$(aws ssm get-parameter --name "/terraform-backend/lock-table" --query "Parameter.Value" --output text)
kms_key_id=$(aws ssm get-parameter --name "/terraform-backend/states-kms-key" --query "Parameter.Value" --output text)

# Format the output
cat <<EOF
bucket         = "$bucket"
key            = "my-api-glgxj/terraform.tfstate"
region         = "$region"
dynamodb_table = "$dynamodb_table"
encrypt        = true 
kms_key_id     = "$kms_key_id"
EOF
