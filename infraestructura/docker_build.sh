#!/bin/bash
set -euo pipefail

ACCOUNT="475554724337"
REGION="us-east-1"
APP="ulagos-tin-lab3-web"
ECR_URI="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${APP}"
ALB_URL=$(terraform output -raw alb_dns)
APP_TAG=$(grep -oP 'ecr_image_tag\s*=\s*"\K[^"]+' terraform.tfvars)

echo "Accediendo a ECR"
aws ecr get-login-password --region $REGION \
  | docker login --username AWS \
  --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com

echo "Creando la imagen docker"
docker system prune -f 2>/dev/null
docker rmi $APP:$APP_TAG 2>/dev/null || true
docker build --no-cache -t $APP:$APP_TAG \
  --build-arg ALB_URL="$ALB_URL" \
  ../sitio-web-2/

echo "Probando localmente"
docker run --rm -d -p 8080:80 --name $APP $APP:$APP_TAG
sleep 5
curl -sf http://localhost:8080 \
  && echo "OK: sitio responde" \
  || echo "ERROR: sitio no responde"
docker kill $APP

echo "Pusheando imagen"
docker tag $APP:$APP_TAG $ECR_URI:$APP_TAG
docker push $ECR_URI:$APP_TAG
docker tag $APP:$APP_TAG $ECR_URI:latest

echo "Redeployando ECS"
aws ecs update-service \
  --cluster ULAGOS-TIN-LAB3-CLUSTER \
  --service ULAGOS-TIN-LAB3-service \
  --force-new-deployment \
  --region $REGION
