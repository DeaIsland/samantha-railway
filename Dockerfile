FROM oven/bun:1

# Install Node.js (for Claude Code)
RUN apt-get update && apt-get install -y curl ca-certificates && \
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code@latest

# Create .claude directory structure
RUN mkdir -p \
    /root/.claude/channels/telegram/approved \
    /root/.claude/channels/telegram/inbox \
    /root/.claude/plugins/cache/claude-plugins-official/telegram/0.0.4/skills \
    /root/.claude/learning/context \
    /root/.claude/learning/digests

# Copy .claude config
COPY .claude/settings.json /root/.claude/settings.json
COPY .claude/CLAUDE.md /root/.claude/CLAUDE.md
COPY .claude/channels/telegram/access.json /root/.claude/channels/telegram/access.json
COPY .claude/plugins/installed_plugins.json /root/.claude/plugins/installed_plugins.json
COPY .claude/learning/hot.md /root/.claude/learning/hot.md
COPY .claude/learning/context/general.md /root/.claude/learning/context/general.md

# Copy and build the telegram plugin
COPY .claude/plugins/telegram/ /root/.claude/plugins/cache/claude-plugins-official/telegram/0.0.4/
WORKDIR /root/.claude/plugins/cache/claude-plugins-official/telegram/0.0.4
RUN bun install --no-summary

WORKDIR /workspace

# Required env vars (set in Railway dashboard):
#   ANTHROPIC_API_KEY
#   TELEGRAM_BOT_TOKEN

CMD ["claude", "--channels", "plugin:telegram@claude-plugins-official", "--dangerously-skip-permissions"]
