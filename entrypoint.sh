#!/bin/sh
dir="$HOME/.nanobot"
if [ -d "$dir" ] && [ ! -w "$dir" ]; then
    owner_uid=$(stat -c %u "$dir" 2>/dev/null || stat -f %u "$dir" 2>/dev/null)
    cat >&2 <<EOF
Error: $dir is not writable (owned by UID $owner_uid, running as UID $(id -u)).
Fix: sudo chown -R 1000:1000 ~/.nanobot
EOF
    exit 1
fi

mkdir -p "$dir"
mkdir -p "$dir/workspace"
# Gunakan /data sebagai persistent storage
if [ -d "/data" ]; then
    export HOME_NANOBOT="/data"
    mkdir -p /data
    rm -rf "$dir"
    ln -sf /data "$dir"
fi
python3 - <<'PYEOF'
import os, json
user_id = str(os.environ.get("TELEGRAM_USER_ID", ""))
cfg = {
    "providers": {"openrouter": {"apiKey": os.environ.get("OPENROUTER_API_KEY", "")}},
    "agents": {"defaults": {"provider": "openrouter", "model": os.environ.get("NANOBOT_MODEL", "deepseek/deepseek-r1:free")}},
    "channels": {"telegram": {"enabled": True, "token": os.environ.get("TELEGRAM_BOT_TOKEN", ""), "allowFrom": [user_id]}}
}
open(os.path.expanduser("~/.nanobot/config.json"), "w").write(json.dumps(cfg))
print("Config OK")
PYEOF

exec nanobot gateway
