#!/bin/sh

# Install awscli
apt update && apt install -y awscli

# Set environment variables
eval $(ssh-agent)
export IMAGE_NAME=$BITBUCKET_REPO_SLUG
export DOCKER_BUILDKIT=1
# Configure AWS Credentials
export AWS_REGION=${AWS_REGION}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

# Configure AWS CLI
aws configure set aws_access_key_id ${AWS_ACCESS_KEY_ID}
aws configure set aws_secret_access_key ${AWS_SECRET_ACCESS_KEY}
aws configure set aws_region ${AWS_REGION}

# Set SSH key
mkdir -p $(dirname ${SSH_KEY})
echo ${PRIVATE_KEY} | base64 --decode > ${SSH_KEY}
echo ${PUBLIC_KEY} | base64 --decode > ${SSH_KEY}.pub
chmod 600 ${SSH_KEY}

# Build the docker image
echo "Building the docker image..."
docker build . --tag ${IMAGE_NAME} --file ${DOCKERFILE} --ssh git_ssh_key=${SSH_KEY}

# Login to the docker registry
echo "Logging into the docker registry..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username ${DOCKER_USERNAME} --password-stdin ${REGISTRY}

# Tag the image
docker tag ${IMAGE_NAME} ${REGISTRY}/${REPO}:latest

# Push the image to the registry
echo "Pushing image to registry..."
docker push ${REGISTRY}/${REPO}:latest
