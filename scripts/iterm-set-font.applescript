#!/usr/bin/osascript
-- Set iTerm2 session font to Menlo-Regular 24 for all windows/tabs/sessions.
-- This sends an OSC SetFont escape to each tmux pane (if tmux is running).
-- Run with: osascript scripts/iterm-set-font.applescript

set shellScript to "osc=$'\\033]50;SetFont=Menlo-Regular 24\\a'; " & ¬
  "if command -v tmux >/dev/null 2>&1 && tmux list-panes >/dev/null 2>&1; then " & ¬
  "tmux list-panes -a -F '#{pane_tty}' | while read -r tty; do printf \"$osc\" > \"$tty\"; done; " & ¬
  "else " & ¬
  "echo \"tmux not running; run in a tmux pane: printf '$osc'\"; " & ¬
  "fi"

do shell script shellScript
