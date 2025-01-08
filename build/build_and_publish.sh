#!/bin/bash

. ${0%/*}/fetch_latest_helm_chart.sh
. ${0%/*}/update_docker_files_with_latest_digest.sh
#Build new images if there is a change in Dockerfiles
if [ "$(find . -name 'Dockerfile*' -exec git diff --exit-code {} \;)" == '' ]; then
    echo 'Skipping build images stage as there are no changes to Dockerfiles !!!'
else
    . ${0%/*}/build_images.sh
    . ${0%/*}/update_image_config_with_latest_digest.sh
fi

cp -r build/ea_files/helm-templates/* ibm-connectivity-pack/templates
cp -r build/ea_files/docs/* ibm-connectivity-pack/

# Remove existing connector JAR and fetch the latest
. ${0%/*}/fetch_latest_connector_jar.sh