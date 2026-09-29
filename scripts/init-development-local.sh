#!/usr/bin/env bash
# Clones (or updates) every Patito repo into ./src and prepares the local dev config.
# Usage: ./scripts/init-development-local.sh [--https] [--up]
set -euo pipefail

cd "$(dirname "$0")/.."

ORG_URL="git@github.com:OnlineJudgeBo"
START=false
for arg in "$@"; do
  case "$arg" in
    --https) ORG_URL="https://github.com/OnlineJudgeBo" ;;
    --up) START=true ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

# directory:repository:branch
REPOS=(
  "patito-client-web:patito-client-web:patito2-0"
  "onlinejudgebo-admin-api:onlinejudgebo-admin-api:develop"
  "patito-admin-front:patito-admin-front:main"
  "patito-ide:patito-ide:main"
  "patito-ide-lsp-server:patito-ide-lsp-server:main"
  "onlinejudge-kernel:onlinejudge-kernel:master"
)

mkdir -p src
for entry in "${REPOS[@]}"; do
  IFS=: read -r dir repo branch <<<"$entry"
  if [ -d "src/$dir/.git" ]; then
    echo "==> updating src/$dir"
    # Never touch local work: skip the pull when the tree is dirty.
    if [ -n "$(git -C "src/$dir" status --porcelain)" ]; then
      echo "    local changes, pull skipped"
    else
      git -C "src/$dir" pull --ff-only || echo "    pull failed, left as is"
    fi
  else
    echo "==> cloning $repo ($branch) into src/$dir"
    git clone --branch "$branch" "$ORG_URL/$repo.git" "src/$dir"
  fi
done

if [ ! -f .env.development ]; then
  cp .env.development.example .env.development
  # Local-only secrets, generated once per machine.
  for key in MARIADB_ROOT_PASSWORD MARIADB_PASSWORD JWT_SECRET VIBE_IDE_TOKEN_SECRET LSP_AUTH_TOKEN CONTROL_TOKEN_SECRET CONTROL_LOBBY_ENROLL_TOKEN CONTROL_ADMIN_TOKEN; do
    sed -i "s|^$key=.*|$key=$(openssl rand -hex 32)|" .env.development
  done
  echo "==> created .env.development with random local secrets"
fi

# Replaces the .env.local tracked in patito-client-web, so the web uses these values.
set -a
# shellcheck disable=SC1091
. ./.env.development
set +a
mkdir -p config data/dev/judge/data data/dev/judge/etc data/dev/vibe-lsp/workspace control/dev/keys control/dev/config control/dev/data
if [ ! -f control/dev/keys/command-signing.key ]; then
  openssl genpkey -algorithm ed25519 -out control/dev/keys/command-signing.key
  openssl pkey -in control/dev/keys/command-signing.key -pubout -out control/dev/keys/command-signing.pub
fi
cat > config/patito-web.dev.env <<EOF
SITE_ID=1
APP_ENV=development
THEME_TEMPLATE=patito
APP_PREFIX_ROUTE=/oj
APP_DOMAIN=${PATITO_WEB_PUBLIC_URL}/oj
APP_DOMAIN_ADMIN=${ADMIN_UI_PUBLIC_URL}
APP_DOMAIN_API=${ADMIN_API_PUBLIC_URL}
DB_HOST=patito-db
DB_NAME=${MARIADB_DATABASE}
DB_USER=${MARIADB_USER}
DB_PASS=${MARIADB_PASSWORD}
JWT_ISS=${JWT_ISS}
JWT_AUD=${JWT_AUD}
JWT_SECRET_KEY=${JWT_SECRET}
VIBE_IDE_BASE_URL=${VIBE_IDE_PUBLIC_URL}
VIBE_IDE_TOKEN_SECRET=${VIBE_IDE_TOKEN_SECRET}
VIBE_IDE_TOKEN_ISS=${VIBE_IDE_TOKEN_ISS}
VIBE_IDE_TOKEN_AUD=${VIBE_IDE_TOKEN_AUD}
VIBE_IDE_TOKEN_TTL_SECONDS=7200
MAIL_USER_NAME=
MAIL_SUBJECT=Juez Virtual
MAIL_PASSWORD=
TELEGRAM_BOT_TOKEN=
TELEGRAM_CHAT_ID=
EOF
chmod 600 config/patito-web.dev.env
echo "==> wrote config/patito-web.dev.env"

DEV_COMPOSE=(docker compose --env-file .env.development -f docker-compose.dev.yml)
if $START; then
  "${DEV_COMPOSE[@]}" up -d --build
  "${DEV_COMPOSE[@]}" ps
else
  echo
  echo "Ready. Start the stack with:"
  echo "  ${DEV_COMPOSE[*]} up -d --build"
fi
