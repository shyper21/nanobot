PYEOF'
import os, json
user_id = str(os.environ.get("TELEGRAM_USER_ID", ""))

cfg = {
    "providers": {"openrouter": {"apiKey": os.environ.get("OPENROUTER_API_KEY", "")}},
    "agents": {"defaults": {"provider": "openrouter", "model": os.environ.get("NANOBOT_MODEL", "deepseek/deepseek-r1:free")}},
    "channels": {"telegram": {"enabled": True, "token": os.environ.get("TELEGRAM_BOT_TOKEN", ""), "allowFrom": [user_id]}}
}
open(os.path.expanduser("~/.nanobot/config.json"), "w").write(json.dumps(cfg))
print("✅ Config berhasil dibuat")
print(f"📱 Telegram token: {'✓' if os.environ.get('TELEGRAM_BOT_TOKEN') else '✗ KOSONG!'}")
print(f"👤 User ID: {user_id}")
PYEOF
