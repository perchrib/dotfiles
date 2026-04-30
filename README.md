# Dotfiles

## Install .dotfiles on new machine (MAC OS only tested)

Requirements before start:

* git cli

### Installation Alternative 1

1. Clone the repo under the folder: `~/`

```bash
git clone https://github.com/perchrib/dotfiles.git
```

1. Run script:

```bash
./.scripts/main-install.sh
```

1. Installing the brew dependencies: **nrk8s** depends on:

* tap "azure/kubelogin"
* tap "nrkno/hylla"

When installing this package, git require you to input credentials. Git username and password.
This will not work with user password, you need to use a personal access token (PAT) instead of your password. You can create a PAT in your GitHub account settings.

### Installation Alternative 2

1. Run inside `/dotfiles/brew`:

```bash
brew bundle install
```

1. Run inside `/dotfiles`

```bash
# Package specific
stow nvim brew kitty git zsh [other folder names...]

# Stow every package at once
# (ignore hidden folders by default (hidden folders is prefixed with '.'))
# Tip: Run always with --verbose and -n flag (dry run)
stow */
```

## Update .Brewfile

Update brew dependencies:
Example:

```bash
brew bundle dump --global --force
```
