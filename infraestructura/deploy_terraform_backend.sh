#!/bin/bash

# Esto deberia ayudar 
export MSYS2_ARG_CONV_EXCL="*"
# Aprovecharemos el script del laboratorio 1

echo "|== iniciando ==|"
export REGION="us-east-1" 
# Para asegurar la region en cada comando
export AWS_DEFAULT_REGION=$REGION 
# Para que la terminal no se cuelgue con json de confirmacion
export PAGER=cat 
export AWS_PAGER=""
export ACCOUNT=$(aws sts get-caller-identity \
    --query Account \
    --output text)

# export TABLE=GuardadoTerraform
export BUCKET_NAME="bucket-de-${ACCOUNT}para-terrafor-aigues-$(date +%s)"


# Crear S3 bucket
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION"

# Habilitar versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# La creacion de la tabla se comento puesto que terraform tiro un warning
# anunciando que no es necesario dynamodb para lockear el estado
# Se mantiene el bloque como registro historico
# # Crear tabla DynamoDB
# aws dynamodb create-table \
#   --table-name "$TABLE" \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST
#
# Esperar que esté activa
# aws dynamodb wait table-exists --table-name "$TABLE"
