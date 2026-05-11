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

# PUBLIC_PORT = port yang di-expose ke Railway (dari env var PORT)
PUBLIC_PORT=${PORT:-8080}

python3 - <<'PYEOF'
import os, json
user_id = str(os.environ.get("TELEGRAM_USER_ID", ""))

cfg = {
    "providers": {
        "gemini":      {"apiKey": os.environ.get("GEMINI_API_KEY", "")},
        "groq":        {"apiKey": os.environ.get("GROQ_API_KEY", "")},
        "openrouter":  {"apiKey": os.environ.get("OPENROUTER_API_KEY", "")}
    },
    "agents": {
        "defaults": {
            # ─── Ganti default dari Gemini ke OpenRouter ───────────────
            "provider": "openrouter",
            "model":    "deepseek/deepseek-chat"
        }
    },
    "gateway": {
        "host": "0.0.0.0",
        # Gateway health server pakai port internal (bukan public port)
        # supaya tidak bentrok dengan nanobot serve di PUBLIC_PORT
        "port": 18790
    },
    "channels": {
        "telegram": {
            "enabled":   True,
            "token":     os.environ.get("TELEGRAM_BOT_TOKEN", ""),
            "allowFrom": [user_id]
        }
    }
}
open(os.path.expanduser("~/.nanobot/config.json"), "w").write(json.dumps(cfg))
print("Config OK")
PYEOF

echo "Starting nanobot serve on port $PUBLIC_PORT (API)..."
nanobot serve --port "$PUBLIC_PORT" --host 0.0.0.0 &
SERVE_PID=$!

# Tunggu serve siap sebelum gateway jalan
sleep 3

echo "Starting nanobot gateway (Telegram)..."
# Gateway jalan di port 18790 internal — Telegram tidak butuh public port
exec nanobot gateway
