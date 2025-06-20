#!/bin/bash

# Script to synthesize, deploy, or destroy AWS CDK stacks with stack dependencies
# Usage: ./cdk-deploy.sh <action> <use-otlp> <skip-slo>
# Example for deploy: ./cdk-deploy.sh deploy false false
# Example for destroy: ./cdk-deploy.sh destroy
# Example to only synth: ./cdk-deploy.sh synth

ACTION=$1
USE_OTLP=${2:-false}  # Default value is false
SKIP_SLO=${3:-true}   # Default to skip SLO creation

# Check for action parameter
if [[ -z "$ACTION" ]]; then
  echo "Usage: $0 <action>"
  echo "action can be 'synth', 'deploy', or 'destroy'"
  echo "use-otlp is optional and can be 'true' or 'false' (default: false)"
  exit 1
fi

# Run CDK synth once for all stacks
if [[ "$ACTION" == "synth" || "$ACTION" == "deploy" ]]; then
  npm install
  echo "Running CDK bootstrap"
  cdk bootstrap

  rm -rf cdk.out
  echo "Running CDK synth for all stacks..."
  if cdk synth --context enableSlo=True ; then
    echo "CDK synth successful!"
    if [[ "$ACTION" == "synth" ]]; then
      exit 0
    fi
  else
    echo "CDK synth failed. Exiting."
    exit 1
  fi
fi

# Deploy or destroy all stacks in the app
if [[ "$ACTION" == "deploy" ]]; then

  # update vets service config to use the otlp collector when use-otlp is true
  MANIFEST_FILE="./lib/manifests/sample-app/vets-service-deployment.yaml"
  MANIFEST_OTLP_FILE="vets-service-deployment-otlp.yaml"
  if [[ "$USE_OTLP" == "true" ]]; then
    if [[ -f "$MANIFEST_OTLP_FILE" ]]; then
      echo "Replacing $MANIFEST_FILE with $MANIFEST_OTLP_FILE..."
      cp "$MANIFEST_OTLP_FILE" "$MANIFEST_FILE"
    else
      echo "Error: $MANIFEST_OTLP_FILE not found!"
      exit 1
    fi
  else
    echo "Using default manifest file: $MANIFEST_FILE"
  fi

  echo "Starting CDK deployment for all stacks in the app"
  # Deploy the EKS cluster with the sample app first
  if cdk deploy --all --require-approval never; then
    echo "Deployment successful for sample app in EKS Cluster"

    # Skip SLO creation if SKIP_SLO is true
    if [[ "$SKIP_SLO" == "true" ]]; then
      echo "Skipping SLO creation as requested"
    else
      # Once the sample app is deployed, it will take up to 10 minutes for SLO metrics to appear
      echo "Waiting for 10 minutes for SLO metrics to appear..."
      sleep 600
      if cdk deploy --context enableSlo=True --all --require-approval never; then
        echo "Synthetic canary and SLO was deployed successfully"
      else
        echo "Synthetic canary and SLO failed to deploy"
        cdk destroy --context enableSlo=True --all --force --verbose
        exit 1
      fi
    fi
  else
    echo "Deployment failed. Attempting to clean up resources by destroying all stacks..."
    cdk destroy --all --force --verbose
    exit 1
  fi
elif [[ "$ACTION" == "destroy" ]]; then
  echo "Starting CDK destroy for all stacks in the app"
  cdk destroy  --context enableSlo=True --all --force --verbose
  echo "Destroy complete for all stacks in the app"
else
  echo "Invalid action: $ACTION. Please use 'synth', 'deploy', or 'destroy'."
  exit 1
fi
