brew_file_all_packages="../brew/.Brewfile"
brew_file_minimum="../brew/.Brewfile-mini"

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
  while true; do
    read -r -p "Install minimum packages? [y/n] " ans
    case "$ans" in
    y)
      echo "Installing minimum packages..."
      brew bundle --file="$brew_file_minimum"
      break
      ;;
    n)
      echo "Installing all packages..."
      brew bundle --file="$brew_file_all_packages"
      break
      ;;
    *) echo "Please answer y or n." ;;
    esac
  done
}

install_brew_if_not_exists || exit 1
install_brew_packages || exit 1
