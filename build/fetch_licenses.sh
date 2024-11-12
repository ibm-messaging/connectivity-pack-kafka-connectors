#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# You must set the Artifactory credentials:
# $ARTIFACTORY_USERNAME and $ARTIFACTORY_PASSWORD

ARTIFACTORY_URL=https://eu.artifactory.swg-devops.com/artifactory/hyc-qp-artifacts-generic-local/licenses
LICENSE_FILES="LA_en LI_en non_ibm_license notices"
LICENSE_GROUP="EVENT_AUTOMATION CP4I"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <LICENSE_DIR>"
    exit 1
fi

LICENSE_DIR=$1
rm -rf $LICENSE_DIR

echo ""
echo "Download latest license files from Artifactory"
echo ""

for group in $LICENSE_GROUP;do
  mkdir -p ${LICENSE_DIR}/${group}/
  for license_file in $LICENSE_FILES; do
    echo "Downloading: $license_file for $group "

    curl -s -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" \
      -X GET ${ARTIFACTORY_URL}/${group}/latest/${license_file} \
      -H 'Content-Type:application/json' \
      -o ${LICENSE_DIR}/${group}/${license_file}
  done
done

mv ${LICENSE_DIR}/CP4I ${LICENSE_DIR}/CLOUD_PAK

ls -LR ${LICENSE_DIR}