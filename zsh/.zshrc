# Set the path to the lazygit config file
export CONFIG_DIR="$HOME/.config/lazygit"

# Set the width of the output for SQLCMD to prevent too large columns width
export SQLCMDMAXVARTYPEWIDTH=30
export SQLCMDMAXFIXEDTYPEWIDTH=30

# Source secrets export if the file exists
[ -f "$HOME/.zsh_secrets_export" ] && source "$HOME/.zsh_secrets_export"

autoload -U compinit; compinit


function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}

setopt PROMPT_SUBST
# PROMPT='%F{green}[%T]%f@%F{blue}%~%F{red}$(parse_git_branch)%f> '
NEWLINE=$'\n'
PROMPT='@%F{blue}%~%F{red}$(parse_git_branch)%f${NEWLINE}> '

alias sql-feed="sqlcmd -S localhost -U sa -P Secret1234 -d TeksternDb -Q 'select * from Feed' $@"

alias dot='cd ~/dotfiles'
alias tn='cd ~/git/nrk/tilt-tekstern/'

alias ls='ls -GF -C'

# Tips from HomeBrew installation
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# alias lvim="NVIM_APPNAME=lazyvim nvim"
# alias nvim="NVIM_APPNAME= nvim"

# Open zsh config in neovim
alias z="nvim $HOME/.zshrc"
alias s="source $HOME/.zshrc"

# Neovim switch between neovim configs default=lazyvim
function nvims() {
	items=("default (lazyvim)" "nvim-myconfig")
  config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config  " --height=~50% --layout=reverse --border --exit-0)
  if [[ -z $config ]]; then
    echo "Nothing selected"
    return 0
	elif [[ $config == "default (lazyvim)" ]]; then
    config=""
  fi
  NVIM_APPNAME=$config nvim $@
}
#bindkey -s ^n "nvims\n"


# Update secrets used as environment variables
# Verify with "printenv" command
# Delete with "unset <variable_name>"
function update-secrets() {
  filepath_update_secrets="$HOME/dotfiles/.scripts/update-secrets.sh"
  # Set the file executeble
  chmod +x $filepath_update_secrets
  # Run bash script
  . $filepath_update_secrets
}

function brew-dump() {
	brew bundle dump --global --force
}

# Print current kubectl context, cluster, and namespace
k() {
  local CURRENT_CONTEXT CURRENT_CLUSTER CURRENT_NAMESPACE

  CURRENT_CONTEXT=$(kubectl config current-context 2>/dev/null)
  CURRENT_CLUSTER=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CURRENT_CONTEXT')].context.cluster}" 2>/dev/null)
  CURRENT_NAMESPACE=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CURRENT_CONTEXT')].context.namespace}" 2>/dev/null)

  [[ -z "$CURRENT_NAMESPACE" ]] && CURRENT_NAMESPACE="default"

  # 🎨 Your chosen colors
  local GREEN="\033[1;32m"
  local YELLOW="\033[1;33m"
  local RED="\033[1;31m"
  local RESET="\033[0m"

  echo -e "${RED}Current context:${RESET}   ${RED}$CURRENT_CONTEXT${RESET}"
  echo -e "${YELLOW}Current cluster:${RESET}   ${YELLOW}$CURRENT_CLUSTER${RESET}"
  echo -e "${GREEN}Current namespace:${RESET} ${GREEN}$CURRENT_NAMESPACE${RESET}"
}
