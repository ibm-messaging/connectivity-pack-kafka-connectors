#!/bin/bash

export TEMP_DIR="${TEMP_DIR:-temp-helm-chart}"

. ${0%/*}/fetch_latest_helm_chart.sh
. ${0%/*}/update_docker_files_with_latest_digest.sh
rm -rf ${TEMP_DIR}
. ${0%/*}/build_images.sh
. ${0%/*}/update_image_config_with_latest_digest.sh