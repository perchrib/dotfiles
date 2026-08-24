# Enable vim keybindings in the terminal
bindkey -v

# Bind Keys (This works by default, but not with tmux)
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search


# Use escape key to switch to normal mode in vim keybindings, this is useful when using tmux which can interfere with the default "jk" or "jj" keybindings
bindkey '^[' vi-cmd-mode
# Map jk to escape (vi-cmd-mode)
bindkey -M viins 'jk' vi-cmd-mode
# Reduce the delay when switching modes (value is in hundredths of a second)
export KEYTIMEOUT=15

# Set the path to the lazygit config file
export CONFIG_DIR="$HOME/.config/lazygit"

# Set the default editor
export EDITOR='nvim'

# Set the width of the output for SQLCMD to prevent too large columns width
# export SQLCMDMAXVARTYPEWIDTH=30
# export SQLCMDMAXFIXEDTYPEWIDTH=30
export SQLCMD_FORMAT=vertical

# Tips from HomeBrew installation
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Source secrets export if the file exists
[ -f "$HOME/.zsh_secrets_export" ] && source "$HOME/.zsh_secrets_export"

# Initialize Zsh completion system
autoload -Uz compinit; compinit

# Git gh cli completion
eval "$(gh completion -s zsh)"

# Enable globdots to include hidden files in completion
_comp_options+=(globdots)

# Enable kubectl autocompletion
source <(kubectl completion zsh)

# Enable npm autocompletion
eval "$(npm completion 2>/dev/null)" 

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# Enable prompt substitution to allow command output in the prompt
setopt PROMPT_SUBST

function parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p'
}
# PROMPT='%F{green}[%T]%f@%F{blue}%~%F{red}$(parse_git_branch)%f> '
NEWLINE=$'\n'
PROMPT='@%F{blue}%~%F{red}$(parse_git_branch)%f${NEWLINE}> '

alias sql-feed="sqlcmd -S localhost -U sa -P Secret1234 -d TeksternDb -Q 'select * from Feed' $@"

alias dot='cd ~/dotfiles'
alias tn='cd ~/git/nrk/tilt-tekstern/'
alias tb='cd ~/git/nrk/tilt-tekstebanken/'

alias ls='ls -GF -C'
alias c='clear'

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

# Open urls from laspass
# Used with pipe ie: urls | xarg curl | jq, curl $(urls) | jq, websocat $(urls)
function urls() {
  lpass show --notes .urls | tr ' ' '\n' | fzf --prompt=" Open URL  " --height=~50% --layout=reverse --border --exit-0
}

function get() {
  if [[ "$1" == "-j" ]]; then
    curl $(urls) | jq
  else
    curl $(urls)
  fi
}

function web() {
  open $(urls)
}

function brew-dump() {
	brew bundle dump --global --force
}

# JIRA CLI configuration

# Set the pager for Jira CLI to open in Neovim with specific settings (read-only)
export JIRA_PAGER="nvim +Man!"

# Open Jira issues assigned to me and not in Done or Won't fix status
# When in the list, copy key with <C-k>, <v> to view, <m> to update status
function jira() {
  # echo("Usage: j [options]")
  if [[ "$1" == "m" ]]; then
    command jira issue list -s~"Done" -s~"Won't fix" -a$(jira me)
  elif [[ "$1" == "w" ]]; then
    command jira issue list -s~"Done" -s~"Won't fix" -w
  elif [[ "$1" == "todo" ]]; then
    command jira issue list -s"To Do" --order-by rank --reverse
  else
    command jira "$@"
  fi
}

# Print current kubectl context, cluster, and namespace
function k() {
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
  echo -e "Note: switch context and namespace with <kubctx> and <kubens>"
}
