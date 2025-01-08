#!/bin/bash

. ${0%/*}/fetch_latest_helm_chart.sh
. ${0%/*}/update_docker_files_with_latest_digest.sh
. ${0%/*}/build_images.sh
. ${0%/*}/update_image_config_with_latest_digest.sh

cp -r build/ea_files/helm-templates/* ibm-connectivity-pack/templates
cp -r build/ea_files/docs/* ibm-connectivity-pack/

# Remove existing connector JAR and fetch the latest
. ${0%/*}/fetch_latest_connector_jar.sh