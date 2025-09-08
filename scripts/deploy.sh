set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.."; pwd)


bash "$ROOT/scripts/package.sh"
cd "$ROOT/infra"
terraform init -upgrade
terraform fmt
terraform plan -out tfplan
terraform apply -auto-approve tfplan
