#!/usr/bin/env bash

# ============================================================
# Scrapy project bootstrap script
# Usage: ./create_scrapy_project.sh PROJECT_NAME HOST_NAME
# Example: ./create_scrapy_project.sh cloud_sougyotecho xn--pckua2a7gp15o89zb.com
# ============================================================

# ----- Colors -----
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ----- Argument check -----
if [ -z "$1" ]; then
  echo -e "${YELLOW}Usage:${NC} $0 PROJECT_NAME HOST_NAME"
  echo -e "Example: $0 cloud_sougyotecho xn--pckua2a7gp15o89zb.com"
  exit 1
fi

if [ -z "$2" ]; then
  echo -e "${YELLOW}Usage:${NC} $0 PROJECT_NAME HOST_NAME"
  exit 1
fi

PROJECT="$1"
HOST="$2"

# Directory where this script is located (root)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo
echo -e "${BLUE}==== Creating Scrapy project ==== ${NC}"
if ! uv run scrapy startproject "$PROJECT"; then
  echo -e "${RED}[ERROR] Failed to run 'scrapy startproject'${NC}"
  exit 1
fi

cd "$PROJECT" || {
  echo -e "${RED}[ERROR] Cannot change directory to: $PROJECT${NC}"
  exit 1
}

echo
echo -e "${BLUE}==== Creating Spider ==== ${NC}"
if ! uv run scrapy genspider "${PROJECT}_spider" "$HOST"; then
  echo -e "${RED}[ERROR] Failed to run 'scrapy genspider'${NC}"
  exit 1
fi

echo
echo -e "${BLUE}==== Copying common files to project root ==== ${NC}"

# List of files placed in ROOT_DIR that should be copied
COMMON_FILES=(
  export.py
  reorder.py
  Dockerfile
  k3s
  Makefile
)

for F in "${COMMON_FILES[@]}"; do
  if [ -e "${ROOT_DIR}/${F}" ]; then
    echo "cp \"${ROOT_DIR}/${F}\" \"$PWD\""
    cp -f "${ROOT_DIR}/${F}" "$PWD"
  else
    echo -e "${YELLOW}[WARN] ${ROOT_DIR}/${F} not found${NC}"
  fi
done

echo
echo -e "${BLUE}==== Installing dependencies with uv ==== ${NC}"
echo -e "${YELLOW}(Assuming 'uv' is available in your PATH)${NC}"

if ! uv init; then
  echo -e "${RED}[ERROR] Failed to run 'uv init'${NC}"
  exit 1
fi

if ! uv add scrapy scrapy-redis pandas; then
  echo -e "${RED}[ERROR] Failed to run 'uv add'${NC}"
  exit 1
fi

echo
echo -e "${GREEN}==== All done! ==== ${NC}"
echo -e "Project : ${GREEN}${PROJECT}${NC}"
echo -e "Host    : ${GREEN}${HOST}${NC}"
