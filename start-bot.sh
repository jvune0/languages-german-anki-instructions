#!/usr/bin/env bash
# Starts Claude Code with the food diary Telegram bot.
# All bots live in one tmux session $SESSION, each in its own window named $BOT.
# If the bot's window already exists, does nothing.
# Exit codes: 0 - started, 2 - already running, other - error.
# Usage: start-bot.sh [-a|--attach]  (-a: also attach to the bot's window)

BOT=tg-anki                 # bot folder: ~/.claude/channels/$BOT (holds .env with the token)
SESSION=${TG_BOTS_SESSION:-bots}  # shared tmux session name
DIR="$(cd "$(dirname "$0")" && pwd)"
CMD="TELEGRAM_STATE_DIR=$HOME/.claude/channels/$BOT claude --channels plugin:telegram@claude-plugins-official"

STATUS=0
if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  tmux new -d -s "$SESSION" -n "$BOT" -c "$DIR" "$CMD" || exit 1
elif ! tmux list-windows -t "$SESSION" -F '#W' | grep -qxF "$BOT"; then
  tmux new-window -d -t "$SESSION:" -n "$BOT" -c "$DIR" "$CMD" || exit 1
else
  STATUS=2
fi

# Attach only on request and only with a terminal
[[ "$1" == "-a" || "$1" == "--attach" ]] && [ -t 1 ] || exit $STATUS

if [ -n "$TMUX" ]; then
  tmux switch-client -t "$SESSION:$BOT"
else
  exec tmux attach -t "$SESSION:$BOT"
fi
