#!/bin/bash

# This Script reads the image digests from values.yaml in Helm Chart and replaces Dockerfiles with the latest digest values

SED=sed
if [ "$(uname -s)" == "Darwin" ]; then
  SED=gsed
fi

echo "Read digest values from Helm Chart"
#Variables
IMAGE_PREFIX="us.icr.io/conn-pack-prod-ns/"
PREHOOK_DIGEST="connectivity-pack-prehook@$(yq eval '.preHook.digest' "ibm-connectivity-pack/values.yaml")"
PROXY_DIGEST="connectivity-pack-proxy@$(yq eval '.proxy.digest' "ibm-connectivity-pack/values.yaml")"
ACTION_DIGEST="action-connectors@$(yq eval '.action.digest' "ibm-connectivity-pack/values.yaml")"
EVENT_DIGEST="event-connectors@$(yq eval '.event.digest' "ibm-connectivity-pack/values.yaml")"

echo "Replacing digest values in Dockerfiles"

echo "Using digest value ${PREHOOK_DIGEST} for connectivity-pack-prehook"
${SED} -i 's+'${IMAGE_PREFIX}'connectivity-pack-prehook@.*+'${IMAGE_PREFIX}${PREHOOK_DIGEST}'+g' build/Dockerfile.connectivity-pack-prehook

echo "Using digest value ${PROXY_DIGEST} for connectivity-pack-proxy"
${SED} -i 's+'${IMAGE_PREFIX}'connectivity-pack-proxy@.*+'${IMAGE_PREFIX}${PROXY_DIGEST}'+g' build/Dockerfile.connectivity-pack-proxy

echo "Using digest value ${ACTION_DIGEST} for action-connectors"
${SED} -i 's+'${IMAGE_PREFIX}'action-connectors@.*+'${IMAGE_PREFIX}${ACTION_DIGEST}'+g' build/Dockerfile.action-connectors

echo "Using digest value ${EVENT_DIGEST} for event-connectors"
${SED} -i 's+'${IMAGE_PREFIX}'event-connectors@.*+'${IMAGE_PREFIX}${EVENT_DIGEST}'+g' build/Dockerfile.event-connectors