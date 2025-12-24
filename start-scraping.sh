#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$1" ] || [ -z "$2" ]; then
  echo -e "${YELLOW}Usage:${NC} $0 PROJECT_NAME HOST_NAME"
  exit 1
fi

PROJECT="$1"
HOST="$2"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
: "${STREAM_TEMPLATE_PATH:=$ROOT_DIR}"
PYTHON_PATH="${STREAM_TEMPLATE_PATH}/.venv/bin/python3.10"

if [ ! -x "$PYTHON_PATH" ]; then
  echo -e "${RED}[ERROR] Python not found: $PYTHON_PATH${NC}"
  exit 1
fi

echo
echo -e "${BLUE}==== Creating Scrapy project ==== ${NC}"
${PYTHON_PATH} -m scrapy startproject "$PROJECT" || {
  echo -e "${RED}[ERROR] scrapy startproject failed${NC}"
  exit 1
}

cd "$PROJECT" || {
  echo -e "${RED}[ERROR] Cannot cd to $PROJECT${NC}"
  exit 1
}

echo
echo -e "${BLUE}==== Generating settings.py ==== ${NC}"
${PYTHON_PATH} "${ROOT_DIR}/render.py" \
  --project-name "$PROJECT" \
  --template-dir "$ROOT_DIR" \
  --template-file "templates/settings.py.j2" \
  --output-path "$PWD/$PROJECT/settings.py" || {
  echo -e "${RED}[ERROR] Failed to generate settings.py${NC}"
  exit 1
}

echo
echo -e "${BLUE}==== Generating Makefile ==== ${NC}"
${PYTHON_PATH} "${ROOT_DIR}/render.py" \
  --project-name "$PROJECT" \
  --template-dir "$ROOT_DIR" \
  --template-file "templates/Makefile.j2" \
  --output-path "$PWD/Makefile" || {
  echo -e "${RED}[ERROR] Failed to generate Makefile${NC}"
  exit 1
}

echo
echo -e "${BLUE}==== Creating Spider ==== ${NC}"
${PYTHON_PATH} -m scrapy genspider "${PROJECT}_s" "$HOST" || {
  echo -e "${RED}[ERROR] scrapy genspider failed${NC}"
  exit 1
}

echo
echo -e "${GREEN}==== All done! ==== ${NC}"
echo -e "Project : ${GREEN}${PROJECT}${NC}"
echo -e "Host    : ${GREEN}${HOST}${NC}"
