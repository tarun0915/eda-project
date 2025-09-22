#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [echo|disk]"
  exit 1
}

[[ $# -lt 1 ]] && usage
EVENT="$1"

: "${WEBHOOK_URL:?Set WEBHOOK_URL env var}"
: "${EDA_TOKEN:?Set EDA_TOKEN env var}"

case "$EVENT" in
  echo)
    DATA='{"hello":"world","note":"echo test"}'
    ;;
  disk)
    DATA=$(cat "$(dirname "$0")/../tests/payloads/webhook_disk_full.json")
    ;;
  *)
    usage
    ;;
esac

curl -sS -X POST "$WEBHOOK_URL"   -H "Content-Type: application/json"   -H "X-EDA-Token: $EDA_TOKEN"   -d "$DATA" | jq . || true

echo
echo "POSTed $EVENT event to $WEBHOOK_URL"
