#!/usr/bin/env bash
# =============================================================================
#  Container Spin-Up Script — prasish
#  Starts all dev containers using podman-compose (or docker compose)
#
#  Stacks:
#    dev-services/   → MySQL 8.0  + Redis 7   + Adminer   (always-on dev tools)
#    subscription/   → Postgres 16-alpine + Redis 7-alpine (subscription project)
#    seatflow/       → Postgres 15 + Redis 7              (seatflow project)
#
#  Usage:
#    bash spin-up.sh             # start all stacks
#    bash spin-up.sh dev         # start only dev-services
#    bash spin-up.sh subscription
#    bash spin-up.sh seatflow
#    bash spin-up.sh stop        # stop all stacks
#    bash spin-up.sh pull        # pull/refresh all images
# =============================================================================

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prefer podman-compose, fall back to docker compose
if command -v podman-compose &>/dev/null; then
  COMPOSE="podman-compose"
elif command -v docker &>/dev/null && docker compose version &>/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose &>/dev/null; then
  COMPOSE="docker-compose"
else
  echo -e "${YELLOW}Neither podman-compose nor docker compose found.${NC}"
  echo "Install with: sudo apt install podman-compose"
  exit 1
fi

echo -e "${CYAN}Using: $COMPOSE${NC}"

# ── Stack definitions ──────────────────────────────────────────────────────
declare -A STACKS=(
  [dev]="$SCRIPT_DIR/dev-services/compose.yml"
  [subscription]="$SCRIPT_DIR/subscription/docker-compose.yml"
  [seatflow]="$SCRIPT_DIR/seatflow/docker-compose.yml"
)

start_stack() {
  local name="$1"
  local file="${STACKS[$name]}"
  echo -e "\n${BOLD}▶ Starting stack: $name${NC}"
  echo -e "  File: $file"
  $COMPOSE -f "$file" up -d
  echo -e "${GREEN}  ✓ $name is up${NC}"
}

stop_stack() {
  local name="$1"
  local file="${STACKS[$name]}"
  echo -e "\n${BOLD}■ Stopping stack: $name${NC}"
  $COMPOSE -f "$file" down
  echo -e "${GREEN}  ✓ $name stopped${NC}"
}

pull_stack() {
  local name="$1"
  local file="${STACKS[$name]}"
  echo -e "\n${BOLD}↓ Pulling images: $name${NC}"
  $COMPOSE -f "$file" pull
}

show_status() {
  echo -e "\n${BOLD}${CYAN}Container status:${NC}"
  if command -v podman &>/dev/null; then
    podman ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
  else
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
  fi
}

# ── Port conflict check ────────────────────────────────────────────────────
check_ports() {
  echo -e "${CYAN}Checking for port conflicts...${NC}"
  for port in 3306 5432 6379 8081; do
    if ss -tlnp 2>/dev/null | grep -q ":$port "; then
      echo -e "  ${YELLOW}⚠ Port $port is already in use — you may have a conflict${NC}"
    fi
  done
}

# ── Main ───────────────────────────────────────────────────────────────────
ARG="${1:-all}"

case "$ARG" in
  stop)
    for name in "${!STACKS[@]}"; do stop_stack "$name"; done
    show_status
    ;;
  pull)
    for name in "${!STACKS[@]}"; do pull_stack "$name"; done
    ;;
  dev|subscription|seatflow)
    check_ports
    start_stack "$ARG"
    show_status
    ;;
  all)
    check_ports
    for name in dev subscription seatflow; do
      start_stack "$name"
    done
    show_status
    ;;
  status)
    show_status
    ;;
  *)
    echo "Usage: $0 [all|dev|subscription|seatflow|stop|pull|status]"
    exit 1
    ;;
esac

echo ""
echo -e "${BOLD}Port map:${NC}"
echo -e "  MySQL 8.0     → localhost:3306  (root pass: Test123)"
echo -e "  Adminer       → http://localhost:8081"
echo -e "  Postgres 16   → localhost:5432  (subscription / subscription_db)"
echo -e "  Postgres 15   → localhost:5432  (postgres / seatflow)  ← conflicts with above if both up"
echo -e "  Redis         → localhost:6379"
echo -e ""
echo -e "${YELLOW}Note: subscription and seatflow both use port 5432 — start only one at a time.${NC}"
