#!/bin/bash
set -euo pipefail

ACCOUNT="475554724337"
REGION="us-east-1"
APP="ulagos-tin-lab3-web"
ECR_URI="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${APP}"
TIMESTAMP=$(date +%s)

echo "Accediendo a ECR"
aws ecr get-login-password --region $REGION \
  | docker login --username AWS \
  --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com

echo "Creando la imagen docker"
docker system prune -f 2>/dev/null
docker rmi $APP:$TIMESTAMP 2>/dev/null || true
docker build --no-cache -t $APP:$TIMESTAMP ../sitio-web/

echo "Probando localmente"
docker run --rm -d -p 8080:80 --name $APP $APP:$TIMESTAMP
sleep 5
curl -sf http://localhost:8080 \
  && echo "OK: sitio responde" \
  || echo "ERROR: sitio no responde"
docker kill $APP

echo "Pusheando imagen"
docker tag $APP:$TIMESTAMP $ECR_URI:$TIMESTAMP
docker push $ECR_URI:$TIMESTAMP

echo "Redeployando ECS"
aws ecs update-service \
  --cluster ULAGOS-TIN-LAB3-CLUSTER \
  --service ULAGOS-TIN-LAB3-service \
  --force-new-deployment \
  --region $REGION
sed -i "s/ecr_image_tag = .*/ecr_image_tag = \"$TIMESTAMP\"/" terraform.tfvars
