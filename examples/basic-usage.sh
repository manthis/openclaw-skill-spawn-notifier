#!/bin/bash
# Basic usage of spawn-notify.sh

# Simple spawn with notification
spawn-notify.sh --task "Analyze codebase and generate documentation" --model "anthropic/claude-sonnet-4-5"

# With custom label and timeout
spawn-notify.sh --task "Build and deploy website" --model "anthropic/claude-opus-4-6" --label "deploy-website" --timeout 3600

# Dry run (preview notification without spawning)
spawn-notify.sh --task "Test task" --model "anthropic/claude-sonnet-4-5" --dry-run

# Skip notification
spawn-notify.sh --task "Quick task" --model "anthropic/claude-sonnet-4-5" --no-notify
