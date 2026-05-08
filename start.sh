#!/bin/bash
mkdir -p ~/.nanobot

cat > ~/.nanobot/config.json << EOF
{
  "providers": {
    "openrouter": {
      "apiKey": "${OPENROUTER_API_KEY}"
    }
  },
  "agents": {
    "defaults": {
      "provider": "openrouter",
      "model": "${NANOBOT_MODEL:-deepseek/deepseek-r1:free}"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "${TELEGRAM_BOT_TOKEN}",
      "allowFrom": ["${TELEGRAM_USER_ID}"]
    }
  }
}
EOF

pip install nanobot-ai --quiet
nanobot gateway
