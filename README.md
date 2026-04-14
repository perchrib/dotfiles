# Dotfiles

## Usage

Use `symlinks.txt` to store every dependencies to use the `stow` command.

Example: 

```bash
cat symlinks.txt | xargs -L 1 stow -v:
```

