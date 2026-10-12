#!/usr/bin/env bash
set -euo pipefail

CONF_PATH="${CONF:?CONF is required}"
mkdir -p "$(dirname "$CONF_PATH")"

: "${OJ_HOST_NAME:?OJ_HOST_NAME is required}" "${OJ_USER_NAME:?OJ_USER_NAME is required}"
: "${OJ_PASSWORD:?OJ_PASSWORD is required}" "${OJ_DB_NAME:?OJ_DB_NAME is required}"

# python3 comes with the judge image and escapes the password correctly.
python3 - > "$CONF_PATH" <<'PY'
import json, os

env = os.environ
print(json.dumps({
    "dbHost": env["OJ_HOST_NAME"],
    "dbPort": int(env.get("OJ_PORT_NUMBER") or 3306),
    "dbUser": env["OJ_USER_NAME"],
    "dbPassword": env["OJ_PASSWORD"],
    "dbName": env["OJ_DB_NAME"],
    "parallel": int(env.get("OJ_RUNNING") or 2),
    "sleepSeconds": int(env.get("OJ_SLEEP_TIME") or 5),
    "bonusTimeSeconds": int(env.get("OJ_JAVA_TIME_BONUS") or 2),
    "bonusMemoryMB": int(env.get("OJ_JAVA_MEMORY_BONUS") or 64),
    "javaXms": env.get("OJ_JAVA_XMS") or "-Xms64m",
    "javaXmx": env.get("OJ_JAVA_XMX") or "-Xmx128m",
    "similarity": (env.get("OJ_SIM_ENABLE") or "1") != "0",
}, indent=2))
PY

chmod 600 "$CONF_PATH"
echo "Generated $CONF_PATH"
