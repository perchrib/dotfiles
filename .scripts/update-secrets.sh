#!/bin/bash
if command -v lpass >/dev/null 2>&1; then
  echo "Updating zsh_secrets_export"
  if ! lpass show --notes .zsh_secrets_export >"$HOME/.zsh_secrets_export"; then
    echo "Error: Failed to retrieve secrets from lpass" >&2
    exit 1
  fi
  source "$HOME/.zsh_secrets_export"
  printf "Secrets updated:\n"
  cat "$HOME/.zsh_secrets_export"
else
  echo "lpass is not installed"
fi
