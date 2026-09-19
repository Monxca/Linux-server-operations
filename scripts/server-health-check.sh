#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_DIR=$(dirname "$SCRIPT_DIR")
LOG_DIR="$PROJECT_DIR/monitoring"
LOG_FILE="$LOG_DIR/health-check.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

CURRENT_TIME=$(date '+%Y-%m-%d %H:%M:%S')
SERVICE_NAME="nginx"
PORT=80
URL="http://localhost"
OVERALL_STATUS=0
DISK_THRESHOLD=80
DISK_USAGE=$(df -h / | tail -n 1 | awk '{print $5}' | tr -d '%')
MEMORY_THRESHOLD=80
TOTAL_MEMORY=$(free -m | awk '/^Mem:/ {print $2}')
USED_MEMORY=$(free -m | awk '/^Mem:/ {print $3}')
MEMORY_USAGE=$(( USED_MEMORY * 100 / TOTAL_MEMORY ))

echo "======================================"
echo "Linux Server Health Check"
echo "Time: $CURRENT_TIME"
echo "======================================"

if systemctl is-active --quiet "$SERVICE_NAME"
then
    echo "[OK] $SERVICE_NAME service is active"
else
    echo "[CRITICAL] $SERVICE_NAME service is inactive"
    OVERALL_STATUS=1
fi

if ss -lntH "sport = :$PORT" | grep -q .
then
    echo "[OK] TCP port $PORT is listening"
else
    echo "[CRITICAL] TCP port $PORT is not listening"
    OVERALL_STATUS=1
fi

HTTP_STATUS=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 5 "$URL")
CURL_EXIT_CODE=$?

if [ "$CURL_EXIT_CODE" -eq 0 ] && [ "$HTTP_STATUS" -eq 200 ]
then
    echo "[OK] Website returned HTTP $HTTP_STATUS"
else
    echo "[CRITICAL] Website check failed: curl=$CURL_EXIT_CODE http=$HTTP_STATUS"
    OVERALL_STATUS=1
fi

if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]
then
    echo "[CRITICAL] Disk usage is $DISK_USAGE% (threshold: $DISK_THRESHOLD%)"
    OVERALL_STATUS=1
else
    echo "[OK] Disk usage is $DISK_USAGE% (threshold: $DISK_THRESHOLD%)"
fi

if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]
then
    echo "[CRITICAL] Memory usage is $MEMORY_USAGE% (threshold: $MEMORY_THRESHOLD%)"
    OVERALL_STATUS=1
else
    echo "[OK] Memory usage is $MEMORY_USAGE% (threshold: $MEMORY_THRESHOLD%)"
fi

echo "======================================"

if [ "$OVERALL_STATUS" -eq 0 ]
then
    echo "Overall status: HEALTHY"
else
    echo "Overall status: UNHEALTHY"
fi

echo "======================================"

exit "$OVERALL_STATUS"
