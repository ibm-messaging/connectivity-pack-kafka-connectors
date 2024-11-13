#!/bin/bash

if [ -z "$ARTIFACTORY_USERNAME" ]; then
    echo "ARTIFACTORY_USERNAME and ARTIFACTORY_PASSWORD not set. Aborting build..."
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

# Docker login
echo "Logging into Docker..."
echo "$ARTIFACTORY_PASSWORD" | docker login -u "$ARTIFACTORY_USERNAME" --password-stdin "$HELM_REPO_URL"
if [ $? -ne 0 ]; then
  echo "Docker login failed."
  exit 1
fi

# Helm registry login
echo "Logging into Helm registry..."
echo "$ARTIFACTORY_PASSWORD" | helm registry login --username "$ARTIFACTORY_USERNAME" --password-stdin "$HELM_REPO_URL"
if [ $? -ne 0 ]; then
  echo "Helm registry login failed."
  exit 1
fi

# Pull the Helm chart
echo "Pulling Helm chart $CHART_NAME version $CHART_VERSION from $HELM_REPO_URL..."
helm pull "oci://$HELM_REPO_URL/$HELM_REPO_PATH/$CHART_NAME" --version "$CHART_VERSION"
if [ $? -ne 0 ]; then
  echo "Failed to pull Helm chart."
  exit 1
fi

# Extract the tarball
TARBALL="${CHART_NAME}-${CHART_VERSION}.tgz"
echo "Extracting $TARBALL ..."
tar -xzf "$TARBALL"
if [ $? -ne 0 ]; then
  echo "Failed to extract Helm chart."
  exit 1
fi

# Remove the tarball after extraction
echo "Removing the downloaded tarball $TARBALL..."
rm -f "$TARBALL"

echo "Helm chart pulled and extracted successfully."
