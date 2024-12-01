#!/bin/bash

rm -rf ibm-connectivity-pack/

. ${0%/*}/fetch_latest_helm_chart.sh
. ${0%/*}/update_docker_files_with_latest_digest.sh
. ${0%/*}/build_images.sh
. ${0%/*}/update_image_config_with_latest_digest.sh

cp -r build/ea_files/helm-templates/* ibm-connectivity-pack/templates
cp -r build/ea_files/docs/* ibm-connectivity-pack/

# Remove existing licenses under root directory and helm chart
rm -rf license
rm -rf ibm-connectivity-pack/license
# Copy new licenses under root directory and helm chart
mkdir -p license
cp -r build/licenses/* license/
mkdir -p ibm-connectivity-pack/license
cp -r build/licenses/* ibm-connectivity-pack/license/

# Remove existing connector JAR and fetch the latest
. ${0%/*}/fetch_latest_connector_jar.sh