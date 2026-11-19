# Global instructions

## Dotfiles are symlinks

Dotfiles in `~` (e.g. `~/.zshrc`, tmux, git, kitty, nvim config) are GNU stow symlinks into `~/dotfiles/<package>/`. The Edit/Write tools refuse to write through symlinks, so resolve the path first (`readlink ~/.zshrc` → `~/dotfiles/zsh/.zshrc`) and edit the target under `~/dotfiles/` directly.
