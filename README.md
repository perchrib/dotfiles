# Dotfiles

## Install dotfiles on new machine (MAC OS only tested)

Requirements before start:
 - git cli
 - brew

1. Clone the repo under the folder: `~/`

2. Run inside `/dotfiles/brew`:
``bash
brew bundle install
```
3. Run inside `/dotfiles`
```bash
stow nvim brew kitty git zsh [other folder names...]
```


## Update .Brewfile


Update brew dependencies:
Example: 

```bash
brew bundle dump --global --force
```

