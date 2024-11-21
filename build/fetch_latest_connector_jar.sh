#!/bin/bash

# This Script fetches the latest connector JAR from artifactory with version <CHART_VERSION>

if [ -z "$ARTIFACTORY_USERNAME" ]; then
    echo "ARTIFACTORY_USERNAME and ARTIFACTORY_PASSWORD not set. Aborting build..."
    exit 1
fi

if [ -z "$CHART_VERSION" ]; then
    echo "CHART_VERSION not set. Aborting build"
    exit 1
fi

#Remove existing connector JAR
find ./connectors -name "*.jar" | xargs rm -r

# Connectivity Pack Source Connector
curl -sSf -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" "https://eu-public.artifactory.swg-devops.com/artifactory/hyc-qp-stable-docker-local/event-integration/eventstreams/connectivity-pack-kafka-connectors/connectivity-pack-source-connector/connectivity-pack-source-connector-${CHART_VERSION}-jar-with-dependencies-latest.jar" --output connectors/connectivity-pack-source-connector-${CHART_VERSION}-jar-with-dependencies.jar
