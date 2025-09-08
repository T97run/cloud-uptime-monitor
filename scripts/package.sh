set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.."; pwd)


cd "$ROOT/lambdas/pinger" && zip -r "$ROOT/infra/pinger.zip" . >/dev/null
cd "$ROOT/lambdas/reader" && zip -r "$ROOT/infra/reader.zip" . >/dev/null


echo "Zipped to infra/pinger.zip and infra/reader.zip"
