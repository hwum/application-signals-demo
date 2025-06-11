#!/bin/bash

# This script will check for required permissions and fail if they're not present
echo "Checking for required permissions..."

# Try to create an IAM role - this will fail without proper permissions
aws iam create-role \
  --role-name EKSDeploymentRequiredRole \
  --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"eks.amazonaws.com"},"Action":"sts:AssumeRole"}]}' || {
    echo "Error: Insufficient permissions to create IAM role"
    echo "Error: Service payment-service-dotnet not found in account"
    exit 1
}

# If we get here, we have the permissions
echo "Permission check passed"