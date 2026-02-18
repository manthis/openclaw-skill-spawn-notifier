# openclaw-skill-spawn-notifier

🚀 Automatic Telegram notifications when spawning OpenClaw sub-agents.

## Features

- 📋 Formatted notifications with task, model, timeout, and label
- 🤖 Model alias resolution (e.g., `anthropic/claude-opus-4-6` → `Opus 4.6`)
- ⚙️ Configurable via environment variables
- 🔗 Integrates with [openclaw-skill-task-router](https://github.com/manthis/openclaw-skill-task-router)
- 🧪 Dry-run mode for testing

## Installation

```bash
# Clone into your OpenClaw skills directory
cd ~/.openclaw/workspace/skills/
git clone https://github.com/manthis/openclaw-skill-spawn-notifier.git

# Symlink to PATH
ln -sf ~/.openclaw/workspace/skills/openclaw-skill-spawn-notifier/scripts/spawn-notify.sh ~/bin/spawn-notify.sh
chmod +x ~/bin/spawn-notify.sh
```

## Usage

```bash
# Basic
spawn-notify.sh --task "Analyze codebase" --model "anthropic/claude-sonnet-4-5"

# With options
spawn-notify.sh --task "Build project" --model "anthropic/claude-opus-4-6" --label "build" --timeout 3600

# Dry run
spawn-notify.sh --task "Test" --model "anthropic/claude-sonnet-4-5" --dry-run

# No notification
spawn-notify.sh --task "Quick" --model "anthropic/claude-sonnet-4-5" --no-notify
```

## Configuration

Set in `config.env` or as environment variables:

```bash
SPAWN_NOTIFY_CHANNEL=telegram
SPAWN_NOTIFY_TARGET=512593507
SPAWN_NOTIFY_ENABLED=true
```

## License

MIT
