#!/bin/bash
# telegram-notify.sh — Send notifications via OpenClaw message tool
# This is a library file, source it from other scripts.
# Note: In OpenClaw context, the `message` tool is called by the agent, not bash.
# This lib provides a fallback using the openclaw CLI if available.

send_telegram_notify() {
    local message="$1"
    local target="${2:-512593507}"

    # Try openclaw CLI
    if command -v openclaw &>/dev/null; then
        openclaw message send --channel telegram --target "$target" --message "$message" 2>/dev/null && return 0
    fi

    # Fallback: print to stdout for agent to pick up
    echo "[NOTIFY:telegram:${target}] ${message}"
    return 0
}
