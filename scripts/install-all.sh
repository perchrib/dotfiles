#!/bin/bash

# cd to the directory of the script so we can run the other scripts without worrying about the current working directory
# and use relative paths to the other files we need
cd "$(dirname "$0")" || exit

function run_scripts() {
  filepath_update_secrets="./update-secrets.sh"
  filepath_init_git="./init-git.sh"
  # Set the file executeble
  chmod +x "$filepath_update_secrets"
  chmod +x "$filepath_init_git"
  # Run bash scripts
  . $filepath_init_git
  . $filepath_update_secrets
}

function install_brew_if_not_exists() {
  # Check if brew is installed
  if ! command -v brew &>/dev/null; then
    echo "Homebrew not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi
}

function install_brew_packages() {
  brew bundle --file=../brew/.Brewfile
}

function stow_dotfiles() {
  # stow --dir=../dotfiles --target=$HOME --verbose --restow
  ignore_directories_list=("MacOS" "scripts" ".git")
  directories=$(find .. -type d -maxdepth 1 -mindepth 1 | sed s/..\\///)
  stow_directories=()
  ignored_directories=()
  if [ -z "$directories" ]; then
    echo "No directories found to stow."
    return 1
  fi
  for dir in $directories; do
    if printf "%s\n" "${ignore_directories_list[@]}" | grep -Fxq "$dir"; then
      ignored_directories+=("$dir")
      continue
    fi

    stow_directories+=("$dir")
    stow --dir="$HOME/dotfiles" --target="$HOME" --verbose --simulate --restow "$dir"
  done
  printf "\n-------------- Stow completed. Summary: -----------------\n"
  printf "\n--- Stow directories: ---\n"
  printf "%s\n" "${stow_directories[@]}"
  printf "\n--- Ignored directories: ---\n"
  printf "%s\n" "${ignored_directories[@]}"
  printf "\n---------------------------------------------------------\n"
}

run_scripts || exit 1
install_brew_if_not_exists || exit 1
install_brew_packages || exit 1
stow_dotfiles || exit 1

echo "All scripts executed successfully."
