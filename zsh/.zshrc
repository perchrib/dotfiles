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

# Enable workmux autocompletion
eval "$(workmux completions zsh)"

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

alias ws='workmux'

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

# Pick a Jira issue assigned to me and create a workmux worktree: <key>-<name> (lowercase)
# Fetches origin and branches from the latest origin/main (override with --base <ref>).
# The agent prompt runs the /jira Claude skill (claude/.claude/skills/jira).
# Prompts: fzf issue picker → task name → optional extra prompt for the agent.
# In fzf: ctrl-f fullscreen preview, ctrl-o open in nvim, ctrl-/ hide preview, shift-↑/↓ scroll.
#
# Usage:
#   work                    # pick issue, branch from latest origin/main, open window
#   work -b                 # same, but create the tmux window in the background
#   work --base develop     # branch from develop instead (skips the fetch)
#   work -w                 # move uncommitted changes into the new worktree
#
# Example:
#   $ work
#   (pick TILT-945)
#   Task name (TILT-945): db schema
#   Extra prompt (optional): only backend, no review
#   → workmux add tilt-945-db-schema --base origin/main -p "/jira TILT-945 only backend, no review"
function work() {
  local issue key name branch
  issue=$(command jira issue list -s~"Done" -s~"Won't fix" -a"$(command jira me)" \
      --plain --no-headers --columns key,summary,status |
    fzf --prompt=" Jira  " --height=90% --layout=reverse --border --exit-0 \
      --delimiter='\t' \
      --preview='JIRA_PAGER=cat jira issue view {1} --plain --comments 10' \
      --preview-window=right,60%,wrap \
      --header='ctrl-f: fullscreen preview · ctrl-/: hide preview · ctrl-o: open in nvim · shift-↑/↓: scroll' \
      --bind='ctrl-f:change-preview-window(up,99%,wrap|right,60%,wrap)' \
      --bind='ctrl-/:toggle-preview' \
      --bind='ctrl-o:execute(jira issue view {1} --comments 10)' \
      --bind='shift-up:preview-page-up,shift-down:preview-page-down')
  [[ -z $issue ]] && { echo "Nothing selected"; return 0 }
  key=${issue%%$'\t'*}

  vared -p "Task name ($key): " name
  [[ -z $name ]] && { echo "No task name given"; return 1 }

  branch="${key}-${name}"
  branch=${(L)branch}
  branch=${branch//æ/ae}; branch=${branch//ø/o}; branch=${branch//å/a}
  branch=$(print -r -- "$branch" | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')

  local extra
  vared -p "Extra prompt (optional): " extra

  # Branch from the latest remote main (origin/HEAD), unless --base is passed
  local -a base_args
  if (( ! ${@[(I)--base*]} )); then
    echo "Fetching origin..."
    git fetch origin --prune || { echo "git fetch failed"; return 1 }
    local base=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)
    base_args=(--base "$base")
    echo "Base: $base ($(git log -1 --format='%h %s' "$base"))"
  fi

  local prompt="/jira $key${extra:+ $extra}"
  echo "→ workmux add $branch ${base_args[*]} -p \"$prompt\""
  workmux add "$branch" "${base_args[@]}" -p "$prompt" "$@"
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

# Open incognito browser and copy test email to clipboard
function azure() {
  echo -n "tmp652952@nrk.no" | pbcopy
  open -na "Google Chrome" --args --incognito "https://portal.azure.com"
  echo "Copied tmp652952@nrk.no to clipboard and opened incognito window"
}

# Search Google using Antigravity CLI with predefined model and effort
# Renders the response as markdown (via glow if installed) and shows a
# spinner while agy is running.
function g() {
  if [ -z "$*" ]; then
    echo "Usage: g <search query>"
    return 1
  fi

  # Suppress zsh's "[N] PID" background-job notification; we render our own.
  setopt local_options no_notify no_monitor

  local MODEL="${AGY_SEARCH_MODEL:-gemini-3.8-flash}"
  local EFFORT="${AGY_SEARCH_EFFORT:-low}"

  local tmpfile
  tmpfile=$(mktemp -t agy-search) || return 1

  local agy_pid=0
  trap 'kill $agy_pid 2>/dev/null; rm -f "$tmpfile"; printf "\r\e[K\e[?25h"; trap - INT; return 130' INT

  agy --model "$MODEL" --effort "$EFFORT" --dangerously-skip-permissions \
    -p "Search and answer concisely with citations: $*" \
    >"$tmpfile" 2>&1 &
  agy_pid=$!

  local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=1
  local start=$SECONDS
  printf '\e[?25l'
  while kill -0 "$agy_pid" 2>/dev/null; do
    printf '\r\e[K\e[36m%s\e[0m Searching \e[2m[%s effort=%s pid=%d %ds]\e[0m' \
      "${spinner[i]}" "$MODEL" "$EFFORT" "$agy_pid" "$((SECONDS - start))"
    i=$(( i % 10 + 1 ))
    sleep 0.1
  done
  printf '\r\e[K\e[?25h'

  wait "$agy_pid"
  local rc=$?
  trap - INT

  # Pre-process: turn list markers into bold-bullet paragraphs so glow (which
  # collapses list spacing) renders each item with a real blank line between.
  local preprocessed
  preprocessed=$(mktemp -t agy-pre) || { rm -f "$tmpfile"; return 1; }
  perl -0777 -pe '
    s{^(\s*)([-*+])\s+}{\n$1**\x{2022}** }gm;
    s{^(\s*)(\d+\.)\s+}{\n$1**$2** }gm;
  ' "$tmpfile" >"$preprocessed"

  # Render, then underline URLs.
  {
    if command -v glow >/dev/null 2>&1; then
      glow -s dark - <"$preprocessed"
    else
      cat "$preprocessed"
    fi
  } | perl -pe '
    BEGIN { $E = chr(27); $U = $E . "[4m"; $R = $E . "[24m"; }
    s{(https?://[^\s)>]+)}{$U$1$R}g;
  '

  printf '\e[2m[done in %ds]\e[0m\n' "$((SECONDS - start))"

  rm -f "$tmpfile" "$preprocessed"
  return $rc
}

# Quick DuckDuckGo search — no LLM, ~1s. Use for simple lookups where you just
# want links and snippets rather than a synthesized answer.
function gq() {
  if [ -z "$*" ]; then
    echo "Usage: gq <search query>"
    return 1
  fi

  if ! command -v ddgr >/dev/null 2>&1; then
    echo "gq requires ddgr. Install with: brew install ddgr" >&2
    return 1
  fi

  ddgr -n 5 --np "$*"
}
