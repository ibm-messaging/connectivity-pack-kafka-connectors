#!/bin/bash

#Variables
IMAGE_PREFIX="us.icr.io/conn-pack-prod-ns/"
PREHOOK_DIGEST="connectivity-pack-prehook@$(yq eval '.preHook.digest' "ibm-connectivity-pack/values.yaml")"
PROXY_DIGEST="connectivity-pack-proxy@$(yq eval '.proxy.digest' "ibm-connectivity-pack/values.yaml")"
ACTION_DIGEST="action-connectors@$(yq eval '.action.digest' "ibm-connectivity-pack/values.yaml")"
EVENT_DIGEST="event-connectors@$(yq eval '.event.digest' "ibm-connectivity-pack/values.yaml")"

sed -i '' -E "s|(${IMAGE_PREFIX})connectivity-pack-prehook@sha256:[a-f0-9]{64}|\1${PREHOOK_DIGEST}|" "build/Dockerfile.connectivity-pack-prehook"
yq -i ".images.preHook=\"${PREHOOK_DIGEST}\"" "build/image-config.yaml"

sed -i '' -E "s|(${IMAGE_PREFIX})connectivity-pack-proxy@sha256:[a-f0-9]{64}|\1${PROXY_DIGEST}|" "build/Dockerfile.connectivity-pack-proxy"
yq -i ".images.proxy=\"${PROXY_DIGEST}\"" "build/image-config.yaml"

sed -i '' -E "s|(${IMAGE_PREFIX})action-connectors@sha256:[a-f0-9]{64}|\1${ACTION_DIGEST}|" "build/Dockerfile.action-connectors"
yq -i ".images.action=\"${ACTION_DIGEST}\"" "build/image-config.yaml"

sed -i '' -E "s|(${IMAGE_PREFIX})event-connectors@sha256:[a-f0-9]{64}|\1${EVENT_DIGEST}|" "build/Dockerfile.event-connectors"
yq -i ".images.event=\"${EVENT_DIGEST}\"" "build/image-config.yaml"