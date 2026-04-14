#!/bin/bash
COLOR_RED='\e[31m'
COLOR_DEFAULT='\e[0m'

default_email="your_email@example.com"
default_ssh_key_path="$HOME/.ssh/id_rsa"

while true; do
	read -r -p "Enter your git email, press enter for default: '$default_email': " email
	email="${email:-$default_email}"
	echo "You entered: '$email'"
	read -r -p "Accept this email? [y/n] " ans
	case "$ans" in
		y) echo "Email accepted: $email"; break;;
		n) echo "Okay — please re-enter."; ;;
		*) echo "Please answer y or n.";;
	esac
done

printf "${COLOR_RED}Make sure to type in a passphrase for the generated ssh key in the following procedure.\n"
printf "Otherwise this script will not work ${COLOR_DEFAULT}\n"

# Generate ssh keys for github
# This may change in the future see:
# https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
ssh-keygen -t rsa -b 4096 -C "$email" -f "$default_ssh_key_path"
eval "$(ssh-agent -s)"

# enable xtrace/debugging (prints the command to stderr)
set -x

cat <<EOF > ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile $default_ssh_key_path
EOF

# disable xtrace/debugging
set +x

ssh-add --apple-use-keychain "$default_ssh_key_path"
