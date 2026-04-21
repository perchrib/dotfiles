#!/bin/bash

# cd to the directory of the script so we can run the other scripts without worrying about the current working directory
# and use relative paths to the other files we need
cd "$(dirname "$0")" || exit

function run_scripts() {
  filepath_update_secrets="./update-secrets.sh"
  filepath_init_git="./git-ssh-init.sh"
  filepath_brew_install="./brew-install.sh"
  # Set the file executeble
  chmod +x "$filepath_update_secrets"
  chmod +x "$filepath_init_git"
  chmod +x "$filepath_brew_install"
  # Run bash scripts
  . $filepath_init_git
  . $filepath_update_secrets
  . $filepath_brew_install
}

function stow_dotfiles() {
  # Stow all directories in the parent directory (dotfiles) except hidden ones, and print the directories that were stowed
  directories=$(find .. -type d -not -name ".*" -maxdepth 1 -mindepth 1 -prune | sed s/..\\///)
  for dir in $directories; do
    stow --dir="$HOME/dotfiles" --target="$HOME" --verbose --simulate --restow "$dir"
  done

  printf "\n--- Packages that where stowed: ---\n"
  printf "%s" "${directories[@]}"
  printf "\n------------------------------------\n"
}

run_scripts || exit 1
stow_dotfiles || exit 1
#update secrets again to make sure the secrets are loaded in the current shell after stowing the dotfiles
source "$HOME/.zshrc" || exit 1

echo "All scripts executed successfully."
