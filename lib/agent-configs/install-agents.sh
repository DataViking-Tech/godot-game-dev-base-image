#!/bin/bash
# Install Claude Code agent configs from the base image into the current project.
# Called from postCreateCommand — only copies agents that don't already exist,
# so downstream projects can override individual agents by providing their own.

if [ -d /opt/agent-configs/claude-agents ]; then
  mkdir -p .claude/agents
  for f in /opt/agent-configs/claude-agents/*.md; do
    name=$(basename "$f")
    [ -f ".claude/agents/$name" ] || cp "$f" ".claude/agents/$name"
  done
fi
