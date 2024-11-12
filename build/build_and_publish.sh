#!/bin/bash

if [ -z "$ARTIFACTORY_USERNAME" ]; then
    echo "ARTIFACTORY_USERNAME and ARTIFACTORY_PASSWORD not set. Aborting build..."
    exit 1
fi

if [ -z "$US_ICR_IO_USERID" ]; then
    echo "US_ICR_IO_USERID and US_ICR_IO_KEY not set. Aborting build..."
    exit 1
fi

#Docker login to registry
echo $US_ICR_IO_KEY | docker login -u $US_ICR_IO_USERID --password-stdin us.icr.io

set -e

# ignore .git directory when building context
# see https://docs.docker.com/reference/builder/#the-dockerignore-file
echo .git >>.dockerignore

# Download License files from artifactory
./build/fetch_licenses.sh ./build/licenses

if [ -z "$BUILD_NUMBER" ]; then
    echo "This is not a jenkins build. Setting buildx to load and not push images to artifactory"
    echo "export LOAD_OR_PUSH=push to push image to artifactory"
    LOAD_OR_PUSH="load"
    TAG=${TAG:-$(whoami)}
fi

LOAD_OR_PUSH="${LOAD_OR_PUSH:-push}"
PLATFORMS="${PLATFORMS:-linux/amd64}"
BUILD_NUMBER="${BUILD_NUMBER:-0}"
GIT_COMMIT=${GIT_COMMIT:-$(git rev-parse HEAD)}
TEST_REGISTRY="${TEST_REGISTRY:-docker-eu-public.artifactory.swg-devops.com/hyc-qp-docker-local/scratch/eventstreams/connectivity-pack-kafka-connectors}"
MAIN_REGISTRY="${MAIN_REGISTRY:-docker-eu-public.artifactory.swg-devops.com/hyc-qp-stable-docker-local/event-integration/eventstreams/connectivity-pack-kafka-connectors}"
BUILDX="buildx build --cache-to=type=local,dest=${HOME}/buildx_cache --${LOAD_OR_PUSH} --platform ${PLATFORMS} --progress=plain --provenance=false"

TIMESTAMPED_TAG="$(date +"%Y-%m-%d-%H.%M.%S")-${GIT_COMMIT:0:7}"
JENKINS_BUILD_TAG="${BUILD_NUMBER}-${GIT_COMMIT:0:7}"

echo "TIMESTAMPED_TAG................[${TIMESTAMPED_TAG}]"
echo "JENKINS_BUILD_TAG..............[${JENKINS_BUILD_TAG}]"
echo "TAG............................[${TAG}]"
echo "GIT_BRANCH.....................[${GIT_BRANCH}]"
echo "JENKINS_BUILD_NUMBER...........[${BUILD_NUMBER}]"
echo "MAIN_REGISTRY............... ..[${MAIN_REGISTRY}]"
echo "TEST_REGISTRY..................[${TEST_REGISTRY}]"
echo "PLATFORMS......................[${PLATFORMS}]"

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


JOB_NAME_LABEL="connectivity-pack-kafka-connectors"
PRODUCT_NAME="IBM Event Streams"

echo "*** Building and pushing connectivity-pack-prehook images ***"
docker ${BUILDX} -f build/Dockerfile.connectivity-pack-prehook \
    --label release=${RELEASE_VERSION} \
    --label git_commit=${GIT_COMMIT} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.job=${BUILD_NUMBER} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.license="Licensed Materials - Property of IBM" \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.name=${JOB_NAME_LABEL} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.maintainer="${PRODUCT_NAME} <eventstreams@uk.ibm.com>" \
    --label vendor=IBM \
    --label summary="${PRODUCT_NAME}" \
    --label description="${PRODUCT_NAME} is a high-throughput, fault-tolerant, pub-sub technology for building event-driven applications. It is built on top of Apache Kafka(R)" \
    -t "${IMAGE_REGISTRY}/connectivity-pack-prehook:${TIMESTAMPED_TAG}" \
    -t "${IMAGE_REGISTRY}/connectivity-pack-prehook:${JENKINS_BUILD_TAG}" \
    -t "${IMAGE_REGISTRY}/connectivity-pack-prehook:${IMAGE_TAG}" \
    .

digest=$(docker buildx imagetools inspect ${IMAGE_REGISTRY}/connectivity-pack-prehook:${TIMESTAMPED_TAG} --format '{{json .Manifest}}' | jq -r .digest)
echo "${IMAGE_REGISTRY}/connectivity-pack-prehook:${IMAGE_TAG} <br> " >> published_images.txt
echo "${IMAGE_REGISTRY}/connectivity-pack-prehook@${digest} <br> " >> published_images.txt


echo "*** Building and pushing connectivity-pack-proxy images ***"
docker ${BUILDX} -f build/Dockerfile.connectivity-pack-proxy \
    --label release=${RELEASE_VERSION} \
    --label git_commit=${GIT_COMMIT} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.job=${BUILD_NUMBER} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.license="Licensed Materials - Property of IBM" \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.name=${JOB_NAME_LABEL} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.maintainer="${PRODUCT_NAME} <eventstreams@uk.ibm.com>" \
    --label vendor=IBM \
    --label summary="${PRODUCT_NAME}" \
    --label description="${PRODUCT_NAME} is a high-throughput, fault-tolerant, pub-sub technology for building event-driven applications. It is built on top of Apache Kafka(R)" \
    -t "${IMAGE_REGISTRY}/connectivity-pack-proxy:${TIMESTAMPED_TAG}" \
    -t "${IMAGE_REGISTRY}/connectivity-pack-proxy:${JENKINS_BUILD_TAG}" \
    -t "${IMAGE_REGISTRY}/connectivity-pack-proxy:${IMAGE_TAG}" \
    .

digest=$(docker buildx imagetools inspect ${IMAGE_REGISTRY}/connectivity-pack-proxy:${TIMESTAMPED_TAG} --format '{{json .Manifest}}' | jq -r .digest)
echo "${IMAGE_REGISTRY}/connectivity-pack-proxy:${IMAGE_TAG} <br> " >> published_images.txt
echo "${IMAGE_REGISTRY}/connectivity-pack-proxy@${digest} <br> " >> published_images.txt

echo "*** Building and pushing action-connectors images ***"
docker ${BUILDX} -f build/Dockerfile.action-connectors \
    --label release=${RELEASE_VERSION} \
    --label git_commit=${GIT_COMMIT} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.job=${BUILD_NUMBER} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.license="Licensed Materials - Property of IBM" \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.name=${JOB_NAME_LABEL} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.maintainer="${PRODUCT_NAME} <eventstreams@uk.ibm.com>" \
    --label vendor=IBM \
    --label summary="${PRODUCT_NAME}" \
    --label description="${PRODUCT_NAME} is a high-throughput, fault-tolerant, pub-sub technology for building event-driven applications. It is built on top of Apache Kafka(R)" \
    -t "${IMAGE_REGISTRY}/action-connectors:${TIMESTAMPED_TAG}" \
    -t "${IMAGE_REGISTRY}/action-connectors:${JENKINS_BUILD_TAG}" \
    -t "${IMAGE_REGISTRY}/action-connectors:${IMAGE_TAG}" \
    .

digest=$(docker buildx imagetools inspect ${IMAGE_REGISTRY}/action-connectors:${TIMESTAMPED_TAG} --format '{{json .Manifest}}' | jq -r .digest)
echo "${IMAGE_REGISTRY}/action-connectors:${IMAGE_TAG} <br> " >> published_images.txt
echo "${IMAGE_REGISTRY}/action-connectors@${digest} <br> " >> published_images.txt

echo "*** Building and pushing event-connectors images ***"
docker ${BUILDX} -f build/Dockerfile.event-connectors \
    --label release=${RELEASE_VERSION} \
    --label git_commit=${GIT_COMMIT} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.job=${BUILD_NUMBER} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.license="Licensed Materials - Property of IBM" \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.name=${JOB_NAME_LABEL} \
    --label com.ibm.eventstreams.${JOB_NAME_LABEL}.maintainer="${PRODUCT_NAME} <eventstreams@uk.ibm.com>" \
    --label vendor=IBM \
    --label summary="${PRODUCT_NAME}" \
    --label description="${PRODUCT_NAME} is a high-throughput, fault-tolerant, pub-sub technology for building event-driven applications. It is built on top of Apache Kafka(R)" \
    -t "${IMAGE_REGISTRY}/event-connectors:${TIMESTAMPED_TAG}" \
    -t "${IMAGE_REGISTRY}/event-connectors:${JENKINS_BUILD_TAG}" \
    -t "${IMAGE_REGISTRY}/event-connectors:${IMAGE_TAG}" \
    .

digest=$(docker buildx imagetools inspect ${IMAGE_REGISTRY}/event-connectors:${TIMESTAMPED_TAG} --format '{{json .Manifest}}' | jq -r .digest)
echo "${IMAGE_REGISTRY}/event-connectors:${IMAGE_TAG} <br> " >> published_images.txt
echo "${IMAGE_REGISTRY}/event-connectors@${digest} <br> " >> published_images.txt

echo "Note : export LOAD_OR_PUSH=push to push image to artifactory"