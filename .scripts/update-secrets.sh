#!/bin/bash
LPASS_EMAIL="${LPASS_EMAIL:-peberg.91@gmail.com}"
SECRETS_FILE="$HOME/.zsh_secrets_export"

if ! command -v lpass >/dev/null 2>&1; then
	echo "lpass is not installed" >&2
	exit 1
fi

if ! lpass status -q; then
	echo "Not logged in to LastPass, logging in as $LPASS_EMAIL"
	if ! lpass login "$LPASS_EMAIL"; then
		echo "Error: Failed to log in to LastPass" >&2
		exit 1
	fi
fi

echo "Updating zsh_secrets_export"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
if ! lpass show --notes .zsh_secrets_export >"$tmp"; then
	echo "Error: Failed to retrieve secrets from lpass" >&2
	exit 1
fi
chmod 600 "$tmp"
mv "$tmp" "$SECRETS_FILE"

printf "Secrets updated:\n"
sed -nE 's/^(export[[:space:]]+)?([A-Za-z_][A-Za-z0-9_]*)=.*/  \2/p' "$SECRETS_FILE"
echo "Run 's' to load them into your current shell."
