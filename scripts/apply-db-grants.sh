#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "Missing .env. Copy .env.example to .env and edit it first." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1091
. ./.env
set +a

: "${MARIADB_ROOT_PASSWORD:?MARIADB_ROOT_PASSWORD is required}"
: "${MARIADB_USER:?MARIADB_USER is required}"
: "${MARIADB_PASSWORD:?MARIADB_PASSWORD is required}"
: "${MARIADB_DATABASE:?MARIADB_DATABASE is required}"

cat <<SQL | docker compose exec -T patito-db mariadb -uroot -p"${MARIADB_ROOT_PASSWORD}"
CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
GRANT ALL PRIVILEGES ON \`schedule_management\`.* TO '${MARIADB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

echo "Granted ${MARIADB_USER} access to ${MARIADB_DATABASE} and schedule_management."
