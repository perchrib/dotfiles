#!/bin/bash
if command -v lpass >/dev/null 2>&1; then
  echo "Updating zsh_secrets_export"
  lpass show --notes .zsh_secrets_export >~/.zsh_secrets_export
else
  echo "lpass is not installed"
fi
