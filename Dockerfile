FROM oven/bun:1

# Install Node.js (for Claude Code)
RUN apt-get update && apt-get install -y curl ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@latest

# Create non-root user
RUN useradd -m -s /bin/bash claude

# Create .claude directory structure
RUN mkdir -p \
    /home/claude/.claude/channels/telegram/approved \
    /home/claude/.claude/channels/telegram/inbox \
    /home/claude/.claude/plugins/cache/claude-plugins-official/telegram/0.0.4/skills \
    /home/claude/.claude/learning/context \
    /home/claude/.claude/learning/digests

# Copy .claude config
COPY .claude/settings.json /home/claude/.claude/settings.json
COPY .claude/CLAUDE.md /home/claude/.claude/CLAUDE.md
COPY .claude/channels/telegram/access.json /home/claude/.claude/channels/telegram/access.json
COPY .claude/plugins/installed_plugins.json /home/claude/.claude/plugins/installed_plugins.json
COPY .claude/learning/hot.md /home/claude/.claude/learning/hot.md
COPY .claude/learning/context/general.md /home/claude/.claude/learning/context/general.md

# Copy and build the telegram plugin
COPY .claude/plugins/telegram/ /home/claude/.claude/plugins/cache/claude-plugins-official/telegram/0.0.4/
WORKDIR /home/claude/.claude/plugins/cache/claude-plugins-official/telegram/0.0.4
RUN bun install --no-summary

RUN chown -R claude:claude /home/claude/.claude
USER claude

WORKDIR /workspace

# Required env vars (set in Railway dashboard):
#   ANTHROPIC_API_KEY
#   TELEGRAM_BOT_TOKEN

CMD ["claude", "--channels", "plugin:telegram@claude-plugins-official", "--dangerously-skip-permissions"]
