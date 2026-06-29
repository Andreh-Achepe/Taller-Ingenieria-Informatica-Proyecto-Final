#!/bin/bash
set -euo pipefail
source .tinit.env

terraform init \
  -backend-config="bucket=${TF_STATE_BUCKET}" \
  -backend-config="key=${KEY}" \
  -backend-config="region=${AWS_REGION}"
