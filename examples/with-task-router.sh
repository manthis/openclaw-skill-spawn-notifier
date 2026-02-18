#!/bin/bash
# Integration with task-router skill
# task-router.sh generates spawn-notify.sh commands when --use-notify is set

# Get routing decision with notification integration
RESULT=$(task-router.sh --task "Create a new skill and publish on GitHub" --json --use-notify)

# The command field will use spawn-notify.sh instead of sessions_spawn
echo "$RESULT" | jq -r '.command'
# Output: spawn-notify.sh --task 'Create a new skill and publish on GitHub' --model 'anthropic/claude-opus-4-6' --label 'create-a-new-skill'

# Execute the routed command
eval "$(echo "$RESULT" | jq -r '.command')"
