#!/usr/bin/env bash

TARGET=$(
  tmux list-panes -a \
    -F '#{window_index}.#{pane_index}	#{window_name}	#{pane_title}' \
  | column -t -s $'\t' \
  | fzf --reverse --prompt="window> " \
        --header="Ctrl-X: kill pane | Enter: select" \
        --preview 'tmux capture-pane -pt {1} -e' \
        --preview-window=right:60% \
        --bind 'ctrl-x:execute-silent(tmux kill-pane -t {1})+reload(tmux list-panes -a -F "#{window_index}.#{pane_index}'$'\t''#{window_name}'$'\t''#{pane_title}")'
)

[[ -z "$TARGET" ]] && exit 0

PANE=$(echo "$TARGET" | awk '{print $1}')
tmux switch-client -t "$PANE"
