#!/usr/bin/env bash

readarray -t RESULT < <(
  tmux list-panes -a \
    -F '#{window_index}.#{pane_index}	#{window_name}	#{pane_title}' \
  | column -t -s $'\t' \
  | fzf --reverse --prompt="window> " \
        --header="Ctrl-X: kill pane | Ctrl-R: rename window | Enter: select" \
        --preview 'tmux capture-pane -pt {1} -e' \
        --preview-window=right:60% \
        --expect=ctrl-r \
        --bind 'ctrl-x:execute-silent(tmux kill-pane -t {1})+reload(tmux list-panes -a -F "#{window_index}.#{pane_index}'$'\t''#{window_name}'$'\t''#{pane_title}")'
)

[[ ${#RESULT[@]} -eq 0 ]] && exit 0

KEY="${RESULT[0]}"
TARGET="${RESULT[1]}"

[[ -z "$TARGET" ]] && exit 0

PANE=$(echo "$TARGET" | awk '{print $1}')

if [[ "$KEY" == "ctrl-r" ]]; then
  CURRENT_NAME=$(echo "$TARGET" | awk '{print $2}')
  NEW_NAME=$(gum input --placeholder 'window name...' --value "$CURRENT_NAME")
  [[ $? -ne 0 ]] && exit 0
  [[ -z "$NEW_NAME" ]] && exit 0
  tmux rename-window -t "$PANE" "$NEW_NAME"
  exit 0
fi

tmux switch-client -t "$PANE"
