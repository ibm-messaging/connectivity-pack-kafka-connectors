#!/bin/bash

# This Script fetches the latest connector JAR from artifactory with version <CHART_VERSION>

if [ -z "$ARTIFACTORY_USERNAME" ]; then
    echo "ARTIFACTORY_USERNAME and ARTIFACTORY_PASSWORD not set. Aborting build..."
    exit 1
fi

if [ -z "$CONNECTOR_JAR_VERSION" ]; then
    echo "CONNECTOR_JAR_VERSION not set. Aborting build"
    exit 1
fi

#Remove existing connector JAR
echo "Remove existing connector JAR"
mkdir -p build/connector-jar
find ./build/connector-jar/ -name "*.jar" | xargs -r rm || echo "JAR not available"

echo "Download Latest connector JAR from artifactory hyc-qp-stable-docker-local/event-integration/eventstreams/connectivity-pack-kafka-connectors/connectivity-pack-source-connector/connectivity-pack-source-connector/connectivity-pack-source-connector-${CONNECTOR_JAR_VERSION}-jar-with-dependencies-signed.jar"
# Connectivity Pack Source Connector
curl -sSf -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" "https://eu-public.artifactory.swg-devops.com/artifactory/hyc-qp-stable-docker-local/event-integration/eventstreams/connectivity-pack-kafka-connectors/connectivity-pack-source-connector/connectivity-pack-source-connector-${CONNECTOR_JAR_VERSION}-jar-with-dependencies-signed.jar" --output build/connector-jar/connectivity-pack-source-connector-${CONNECTOR_JAR_VERSION}-jar-with-dependencies.jar
if [ $? -ne 0 ]; then
  echo "Connector JAR Download failed."
  exit 1
fi
