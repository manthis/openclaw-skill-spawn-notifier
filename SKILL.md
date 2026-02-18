# openclaw-skill-spawn-notifier

Automatic Telegram notifications when spawning sub-agents.

## What it does

Wraps `sessions_spawn` to send a formatted notification before spawning a sub-agent. Includes task description, model (with human-friendly alias), timeout, and label.

## Usage

```bash
spawn-notify.sh --task "Description" --model "anthropic/claude-opus-4-6" [--label "my-label"] [--timeout 1800]
```

### Options

| Flag | Description | Default |
|------|-------------|---------|
| `--task` | Task description (required) | — |
| `--model` | Model identifier (required) | — |
| `--label` | Sub-agent label | Auto from task |
| `--timeout` | Timeout in seconds | 1800 |
| `--notify-channel` | Notification channel | telegram |
| `--notify-target` | Notification target | 512593507 |
| `--no-notify` | Skip notification | false |
| `--dry-run` | Preview only | false |

### Notification format

```
🚀 Sub-agent lancé

📋 Tâche: Create 6 skills and publish on GitHub
🤖 Modèle: Opus 4.6 (anthropic/claude-opus-4-6)
⏱️ Timeout: 1800s (30min)
🏷️ Label: create-6-skills
```

## Configuration

Environment variables or `config.env`:
- `SPAWN_NOTIFY_CHANNEL` (default: telegram)
- `SPAWN_NOTIFY_TARGET` (default: 512593507)
- `SPAWN_NOTIFY_ENABLED` (default: **false**)

**Note:** Telegram notifications are **disabled by default** to keep spawn workflow fast (< 10s). Enable explicitly via `SPAWN_NOTIFY_ENABLED=true` in `config.env` or use `--notify-channel` flag when needed.

## Integration with task-router

Use `--use-notify` flag with task-router to auto-generate `spawn-notify.sh` commands.

## Agent rule

When spawning sub-agents manually, always use `spawn-notify.sh` instead of raw `sessions_spawn`.
