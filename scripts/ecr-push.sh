#!/bin/sh
#
# Builds a Docker image and pushes it to AWS ECR.
#

source scripts/env.sh env.list

eval $(aws ecr get-login --no-include-email --region $AWS_REGION --profile $AWS_PROFILE)
# N.B.: linux/amd64 is the only platform supported by GitHub Actions currently
docker buildx build --platform linux/amd64,linux/arm64 --push -t mockdusa .
docker tag $DOCKER_TAG $ECR_HOST/$DOCKER_TAG
docker push $ECR_HOST/$DOCKER_TAG
