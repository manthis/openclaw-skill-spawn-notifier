#!/bin/bash
# spawn-notify.sh — Wrapper around sessions_spawn with Telegram notifications
# Usage: spawn-notify.sh --task "..." --model "..." [--label "..."] [--timeout 1800]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/../lib"

# Source config
CONFIG_FILE="${SCRIPT_DIR}/../config.env"
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"

# Defaults
TASK=""
MODEL=""
LABEL=""
TIMEOUT="${SPAWN_NOTIFY_TIMEOUT:-1800}"
NOTIFY_CHANNEL="${SPAWN_NOTIFY_CHANNEL:-telegram}"
NOTIFY_TARGET="${SPAWN_NOTIFY_TARGET:-512593507}"
NOTIFY_ENABLED="${SPAWN_NOTIFY_ENABLED:-true}"
NO_NOTIFY=false
DRY_RUN=false

# Model aliases (function-based for compatibility)
get_model_alias() {
    local model="$1"
    case "$model" in
        "anthropic/claude-opus-4-6") echo "Opus 4.6" ;;
        "anthropic/claude-sonnet-4-5") echo "Sonnet 4.5" ;;
        "anthropic/claude-sonnet-4-6") echo "Sonnet 4.6" ;;
        "openai/gpt-5.3-codex") echo "Codex" ;;
        "openai/o3") echo "o3" ;;
        "google/gemini-2.5-pro") echo "Gemini Pro" ;;
        *) echo "${model##*/}" ;;
    esac
}

usage() {
    cat <<EOF
Usage: spawn-notify.sh --task "description" --model "model" [OPTIONS]

Options:
  --task <description>       Task description (required)
  --model <model>            Model identifier (required)
  --label <label>            Sub-agent label (auto-generated if missing)
  --timeout <seconds>        Timeout in seconds (default: 1800)
  --notify-channel <channel> Notification channel (default: telegram)
  --notify-target <target>   Notification target (default: 512593507)
  --no-notify                Skip notification
  --dry-run                  Show notification without spawning
  -h, --help                 Show this help
EOF
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --task) TASK="$2"; shift 2 ;;
        --model) MODEL="$2"; shift 2 ;;
        --label) LABEL="$2"; shift 2 ;;
        --timeout) TIMEOUT="$2"; shift 2 ;;
        --notify-channel) NOTIFY_CHANNEL="$2"; shift 2 ;;
        --notify-target) NOTIFY_TARGET="$2"; shift 2 ;;
        --no-notify) NO_NOTIFY=true; shift ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown option: $1" >&2; usage ;;
    esac
done

# Validate required args
if [[ -z "$TASK" ]]; then echo "Error: --task is required" >&2; exit 1; fi
if [[ -z "$MODEL" ]]; then echo "Error: --model is required" >&2; exit 1; fi

# Auto-generate label from task if missing
if [[ -z "$LABEL" ]]; then
    LABEL=$(echo "$TASK" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9 ]//g' | awk '{for(i=1;i<=NF && i<=4;i++) printf "%s-", $i; print ""}' | sed 's/-$//' | head -c 40)
fi

# Resolve model alias
MODEL_ALIAS=$(get_model_alias "$MODEL")

# Format timeout human-readable
format_timeout() {
    local secs=$1
    if [[ $secs -ge 3600 ]]; then
        echo "${secs}s ($((secs/3600))h$((secs%3600/60))min)"
    elif [[ $secs -ge 60 ]]; then
        echo "${secs}s ($((secs/60))min)"
    else
        echo "${secs}s"
    fi
}

TIMEOUT_FMT=$(format_timeout "$TIMEOUT")

# Build notification message
build_message() {
    cat <<EOF
🚀 Sub-agent lancé

📋 Tâche: ${TASK}
🤖 Modèle: ${MODEL_ALIAS} (${MODEL})
⏱️ Timeout: ${TIMEOUT_FMT}
🏷️ Label: ${LABEL}
EOF
}

MESSAGE=$(build_message)

# Send notification
if [[ "$NO_NOTIFY" == "false" && "$NOTIFY_ENABLED" == "true" ]]; then
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "=== DRY RUN — Notification preview ==="
        echo "$MESSAGE"
        echo "=== Would send to ${NOTIFY_CHANNEL}:${NOTIFY_TARGET} ==="
        exit 0
    fi

    # Use telegram-notify.sh if available, otherwise just print
    if [[ -f "${LIB_DIR}/telegram-notify.sh" ]]; then
        source "${LIB_DIR}/telegram-notify.sh"
        send_telegram_notify "$MESSAGE" "$NOTIFY_TARGET"
    else
        echo "$MESSAGE"
    fi
fi

# Execute spawn (unless dry-run)
if [[ "$DRY_RUN" == "true" ]]; then
    echo "=== DRY RUN — Would execute: ==="
    echo "sessions_spawn --task '${TASK}' --model '${MODEL}' --label '${LABEL}' --timeout ${TIMEOUT}"
    exit 0
fi

# Spawn the sub-agent
exec sessions_spawn --task "${TASK}" --model "${MODEL}" --label "${LABEL}" --timeout "${TIMEOUT}"
