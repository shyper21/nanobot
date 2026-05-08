import os
import json
import subprocess

# Buat config dari environment variables
os.makedirs(os.path.expanduser('~/.nanobot'), exist_ok=True)

config = {
    "providers": {
        "openrouter": {
            "apiKey": os.environ.get('OPENROUTER_API_KEY', '')
        }
    },
    "agents": {
        "defaults": {
            "provider": "openrouter",
            "model": os.environ.get('NANOBOT_MODEL', 'deepseek/deepseek-r1:free')
        }
    },
    "channels": {
        "telegram": {
            "enabled": True,
            "token": os.environ.get('TELEGRAM_BOT_TOKEN', ''),
            "allowFrom": [os.environ.get('TELEGRAM_USER_ID', '')]
        }
    }
}

config_path = os.path.expanduser('~/.nanobot/config.json')
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("✅ Config berhasil dibuat")
print(f"📁 Lokasi: {config_path}")
print("🚀 Menjalankan nanobot gateway...")

subprocess.run(['python3', '-m', 'nanobot', 'gateway'])
