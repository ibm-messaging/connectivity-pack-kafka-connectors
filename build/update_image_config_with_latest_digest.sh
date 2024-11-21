#!/bin/bash

# This Script identifies the digest value of new docker images built and updates them in image-config.yaml file as well as values.yaml

SED=sed
if [ "$(uname -s)" == "Darwin" ]; then
  SED=gsed
fi

BUILD_NUMBER="${BUILD_NUMBER:-0}"
GIT_COMMIT=${GIT_COMMIT:-$(git rev-parse HEAD)}
TEST_REGISTRY="${TEST_REGISTRY:-docker-eu-public.artifactory.swg-devops.com/hyc-qp-docker-local/scratch/eventstreams/connectivity-pack-kafka-connectors}"
MAIN_REGISTRY="${MAIN_REGISTRY:-docker-eu-public.artifactory.swg-devops.com/hyc-qp-stable-docker-local/event-integration/eventstreams/connectivity-pack-kafka-connectors}"

JENKINS_BUILD_TAG="${BUILD_NUMBER}-${GIT_COMMIT:0:7}"

IMAGE_REGISTRY="${TEST_REGISTRY}"
if [ -n "$TAG" ]; then
    IMAGE_TAG="${TAG}"
else
    if [ "$GIT_BRANCH" = "main" ]; then
        IMAGE_TAG="latest"
        IMAGE_REGISTRY="${MAIN_REGISTRY}"
    else
        IMAGE_TAG="$(echo $GIT_BRANCH | sed -e 's/[^a-zA-Z0-9]/_/g')"
    fi
fi
echo "IMAGE_TAG......................[${IMAGE_TAG}]"
echo "IMAGE_REGISTRY.................[${IMAGE_REGISTRY}]"

# Identifying digest values from Artifactory and using the same to update image-config.yaml as well as values.yaml

PREHOOK_DIGEST=$(docker buildx imagetools inspect ${IMAGE_REGISTRY}/connectivity-pack-prehook:${JENKINS_BUILD_TAG} --format '{{json .Manifest}}' | jq -r .digest)
yq -i ".images.preHook=\"connectivity-pack-prehook@${PREHOOK_DIGEST}\"" "build/image-config.yaml"
yq -i ".preHook.digest=\"${PREHOOK_DIGEST}\"" "ibm-connectivity-pack/values.yaml"
yq -i ".preHook.tag=\"${CHART_VERSION}\"" "ibm-connectivity-pack/values.yaml"

PROXY_DIGEST=$(docker buildx imagetools inspect ${IMAGE_REGISTRY}/connectivity-pack-proxy:${JENKINS_BUILD_TAG} --format '{{json .Manifest}}' | jq -r .digest)
yq -i ".images.proxy=\"connectivity-pack-proxy@${PROXY_DIGEST}\"" "build/image-config.yaml"
yq -i ".proxy.digest=\"${PROXY_DIGEST}\"" "ibm-connectivity-pack/values.yaml"
yq -i ".proxy.tag=\"${CHART_VERSION}\"" "ibm-connectivity-pack/values.yaml"

ACTION_DIGEST=$(docker buildx imagetools inspect ${IMAGE_REGISTRY}/action-connectors:${JENKINS_BUILD_TAG} --format '{{json .Manifest}}' | jq -r .digest)
yq -i ".images.action=\"action-connectors@${ACTION_DIGEST}\"" "build/image-config.yaml"
yq -i ".action.digest=\"${ACTION_DIGEST}\"" "ibm-connectivity-pack/values.yaml"
yq -i ".action.tag=\"${CHART_VERSION}\"" "ibm-connectivity-pack/values.yaml"

EVENT_DIGEST=$(docker buildx imagetools inspect ${IMAGE_REGISTRY}/event-connectors:${JENKINS_BUILD_TAG} --format '{{json .Manifest}}' | jq -r .digest)
yq -i ".images.event=\"event-connectors@${EVENT_DIGEST}\"" "build/image-config.yaml"
yq -i ".event.digest=\"${EVENT_DIGEST}\"" "ibm-connectivity-pack/values.yaml"
yq -i ".event.tag=\"${CHART_VERSION}\"" "ibm-connectivity-pack/values.yaml"

# Update values.yaml with registry and namespace path
yq -i '.image.registry="cp.icr.io"' "ibm-connectivity-pack/values.yaml"
yq -i '.image.path="cp/ibm-eventstreams"' "ibm-connectivity-pack/values.yaml"

# Remove java connectors image details
yq -i '.javaservice = {}' "ibm-connectivity-pack/values.yaml"
yq e -i '.javaservice += {"enable": false}' "ibm-connectivity-pack/values.yaml"

# Update Chart Version and appVersion
yq -i ".version=\"${CHART_VERSION}\"" "ibm-connectivity-pack/Chart.yaml"
yq -i ".appVersion=\"${CHART_VERSION}\"" "ibm-connectivity-pack/Chart.yaml"