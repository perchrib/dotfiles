# Set the path to the lazygit config file
export CONFIG_DIR="$HOME/.config/lazygit"

# Source secrets export if the file exists
[ -f "$HOME/.zsh_secrets_export" ] && source "$HOME/.zsh_secrets_export"

PROMPT='%F{green}[%T]%f@%F{blue}%~%f> '

alias dot='cd ~/dotfiles'
alias ls='ls -GF'

# Tips from HomeBrew installation
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

alias lvim="NVIM_APPNAME=lazyvim nvim"
# alias nvim="NVIM_APPNAME= nvim"
# Open zsh config in neovim with lazyvim config
alias z="lvim $HOME/.zshrc"
alias s="source $HOME/.zshrc"

# Neovim switch between neovim configs
function nvims() {
	items=("default" "lazyvim")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
  elif [[ $config == "default" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}
#bindkey -s ^n "nvims\n"


# Update secrets used as environment variables
# Verify with "printenv" command
# Delete with "unset <variable_name>"
function update-secrets() {
  filepath_update_secrets="$HOME/dotfiles/scripts/update-secrets.sh"
  # Set the file executeble
  chmod +x $filepath_update_secrets
  # Run bash script
  . $filepath_update_secrets
  # Update environment variables where the secrets is stored
  source "$HOME/.zsh_secrets_export"
}

function brew-update-file() {
	brew bundle dump --global --force
}

