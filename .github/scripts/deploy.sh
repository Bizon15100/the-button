#!/bin/bash
set -euo pipefail

IMAGE_NAME=$1
TAG=$2
EC2_HOST=$3
EC2_USER=$4
ENV_NAME=$5

: "${DOCKER_USERNAME:?DOCKER_USERNAME is not set}"
: "${DOCKER_PASSWORD:?DOCKER_PASSWORD is not set}"

echo "Starting deployment of image $IMAGE_NAME:$TAG to server $EC2_HOST in $ENV_NAME environment"

sed -i "s/your_dockerhub_username/$(echo "$IMAGE_NAME" | cut -d '/' -f 1)/" .env.prod
sed -i "s/latest/$TAG/" .env.prod
sed -i "s/localhost,127.0.0.1/localhost,127.0.0.1,$EC2_HOST/" .env.prod

echo "Deployment files have been prepared"
echo "Deploying application..."

scp -i ~/.ssh/deploy_key .env.prod "$EC2_USER@$EC2_HOST:~/.env"
scp -i ~/.ssh/deploy_key docker-compose.yml "$EC2_USER@$EC2_HOST:~/"

ssh -i ~/.ssh/deploy_key "$EC2_USER@$EC2_HOST" << EOF
set -e
echo "$DOCKER_PASSWORD" | docker login docker.io -u "$DOCKER_USERNAME" --password-stdin
docker pull "$IMAGE_NAME:$TAG"
cd ~
docker compose down --remove-orphans || true
docker rm -f the-button the_button_app 2>/dev/null || true
docker compose up -d --pull always
docker ps
EOF

echo "Deployment completed successfully"