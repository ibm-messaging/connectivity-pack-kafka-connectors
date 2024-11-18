#!/bin/bash

# This Script fetches the ibm-connectivity-pack AppConnect Helm Chart with version <CHART_VERSION>

if [ -z "$US_ICR_IO_KEY" ]; then
    echo "US_ICR_IO_USERID and US_ICR_IO_KEY not set. Aborting build..."
    exit 1
fi

if [ -z "$CHART_VERSION" ]; then
    echo "CHART_VERSION not set. Aborting build"
    exit 1
fi

# Chart Details
HELM_REPO_URL="us.icr.io"
HELM_REPO_PATH="conn-pack-prod-ns"
CHART_NAME="ibm-connectivity-pack"
TEMP_DIR="${TEMP_DIR:-temp-helm-chart}"

# Helm registry login
echo "Logging into Helm registry..."
echo "$US_ICR_IO_KEY" | helm registry login --username "$US_ICR_IO_USERID" --password-stdin "$HELM_REPO_URL"
if [ $? -ne 0 ]; then
  echo "Helm registry login failed."
  exit 1
fi

# Pull the Helm chart
echo "Pulling Helm chart ${CHART_NAME} version ${CHART_VERSION} from ${HELM_REPO_URL}"
helm pull "oci://$HELM_REPO_URL/$HELM_REPO_PATH/$CHART_NAME" --version "$CHART_VERSION" --untar --untardir "${TEMP_DIR}"
if [ $? -ne 0 ]; then
  echo "Failed to pull Helm chart."
  exit 1
fi

echo "Helm chart pulled and extracted successfully to directory ${TEMP_DIR}"
