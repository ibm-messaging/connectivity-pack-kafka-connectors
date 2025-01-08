#!/bin/bash

# This Script fetches the ibm-connectivity-pack AppConnect Helm Chart with version <APP_CONNECT_CHART_VERSION>

if [ -z "$US_ICR_PASS" ]; then
    echo "US_ICR_USER and US_ICR_PASS not set. Aborting build..."
    exit 1
fi

if [ -z "$APP_CONNECT_CHART_VERSION" ]; then
    echo "APP_CONNECT_CHART_VERSION not set. Aborting build"
    exit 1
fi

# Chart Details
HELM_REPO_URL="us.icr.io"
HELM_REPO_PATH="conn-pack-prod-ns"
CHART_NAME="ibm-connectivity-pack"

# Helm registry login
echo "Logging into Helm registry $HELM_REPO_URL"
echo "$US_ICR_PASS" | helm registry login --username "$US_ICR_USER" --password-stdin "$HELM_REPO_URL"
if [ $? -ne 0 ]; then
  echo "Helm registry login failed."
  exit 1
fi


echo "Backup EA Readme in helm chart folder"
cp ibm-connectivity-pack/README.md EA_README.md

echo "Backup Apache LICENSE in helm chart folder"
cp ibm-connectivity-pack/LICENSE APACHE_LICENSE

echo "Delete existing helm chart folder"
rm -rf ibm-connectivity-pack/

# Pull the Helm chart
echo "Pulling Helm chart ${CHART_NAME} version ${APP_CONNECT_CHART_VERSION} from ${HELM_REPO_URL}"
helm pull "oci://$HELM_REPO_URL/$HELM_REPO_PATH/$CHART_NAME" --version "$APP_CONNECT_CHART_VERSION" --untar
if [ $? -ne 0 ]; then
  echo "Failed to pull Helm chart."
  exit 1
fi

echo "Helm chart pulled and extracted successfully to ibm-connectivity-pack"

echo "Copy back in EA Readme in helm chart folder"
cp EA_README.md ibm-connectivity-pack/README.md

echo "Copy back in Apache LICENSE in helm chart folder"
cp APACHE_LICENSE ibm-connectivity-pack/LICENSE

echo 'license/' >> ibm-connectivity-pack/.helmignore
