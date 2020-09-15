#!/bin/sh
#
# Builds a Docker image and pushes it to AWS ECR.
#

source scripts/env.sh env.list

docker build -t mockdusa .
eval $(aws ecr get-login --no-include-email --region $AWS_REGION --profile $AWS_PROFILE)
docker tag $DOCKER_TAG $ECR_HOST/$DOCKER_TAG
docker push $ECR_HOST/$DOCKER_TAG
