#!/usr/bin/env bash

set -Eeuo pipefail

BASE_URL="http://127.0.0.1:8088"
EXPECTED_REVISION="${1:?Expected Git revision is required}"

echo "========== DEPLOYMENT VERIFICATION =========="

echo "[1/6] Checking container status"

for container in cis4930-app cis4930-gateway; do
    test "$(docker inspect \
        --format '{{.State.Running}}' "$container")" = "true"

    echo "PASS: $container is running"
done

echo "[2/6] Checking Docker network"

network_members="$(docker network inspect cis4930-pipeline-network \
    --format '{{range .Containers}}{{println .Name}}{{end}}')"

grep -Fxq "cis4930-app" <<< "$network_members"
grep -Fxq "cis4930-gateway" <<< "$network_members"

echo "PASS: Both containers are connected"

echo "[3/6] Checking application health"

ready=false

for attempt in $(seq 1 30); do
    if health="$(curl --noproxy '*' -fsS --max-time 5 \
        "$BASE_URL/health" 2>/dev/null)" &&
        jq -e --arg revision "$EXPECTED_REVISION" \
        '.status == "ok" and .revision == $revision' \
        <<< "$health" >/dev/null; then

        ready=true
        break
    fi

    sleep 2
done

if [ "$ready" != "true" ]; then
    echo "FAIL: Expected application revision is not available"
    exit 1
fi

jq . <<< "$health"

echo "PASS: Health endpoint returned the expected revision"

echo "[4/6] Checking gateway response"

headers="$(curl --noproxy '*' -fsS \
    -D - -o /dev/null "$BASE_URL/health")"

grep -qi '^X-Deployment-Gateway: nginx' <<< "$headers"

echo "PASS: Response routed through NGINX"

echo "[5/6] Checking application homepage"

homepage="$(curl --noproxy '*' -fsS "$BASE_URL/")"

grep -Fq "CI/CD Pipeline Integration" <<< "$homepage"
grep -Fq "$EXPECTED_REVISION" <<< "$homepage"

echo "PASS: Application homepage is available"

echo "[6/6] Checking invalid endpoint"

status_code="$(curl --noproxy '*' -sS -o /dev/null \
    -w '%{http_code}' "$BASE_URL/invalid")"

test "$status_code" = "404"

echo "PASS: Invalid endpoint returned HTTP 404"

echo
docker ps --filter name=cis4930-

echo
echo "========== ALL 6 VERIFICATION CHECKS PASSED =========="
