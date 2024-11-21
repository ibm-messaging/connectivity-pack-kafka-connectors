#!/bin/bash

. ${0%/*}/fetch_latest_helm_chart.sh
. ${0%/*}/update_docker_files_with_latest_digest.sh
. ${0%/*}/build_images.sh
. ${0%/*}/update_image_config_with_latest_digest.sh

# Remove existing licenses under root directory and helm chart
rm -rf license/*
rm -rf ibm-connectivity-pack/license/*
# Copy new licenses under root directory and helm chart
cp build/licenses/* license/
cp -r build/licenses/* ibm-connectivity-pack/license/*

# Remove existing connector JAR and fetch the latest
. ${0%/*}/fetch_latest_connector_jar.sh