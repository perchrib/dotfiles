# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration built on [LazyVim](https://www.lazyvim.org/), a framework that wraps [lazy.nvim](https://github.com/folke/lazy.nvim). The config is part of a larger dotfiles repository (stow-managed). The primary development focus is **.NET/C#** and **TypeScript/Svelte**.

## Architecture

### Entry Point & Loading Order

```
init.lua → lua/config/lazy.lua → LazyVim core + lua/plugins/*.lua
```

- `init.lua` is a single-line bootstrap into `lua/config/lazy.lua`
- `lazy.lua` bootstraps lazy.nvim from GitHub if not present, then loads LazyVim extras (defined in `lazyvim.json`) and auto-imports all specs from `lua/plugins/`
- Files in `lua/config/` (`keymaps.lua`, `options.lua`, `autocmds.lua`) are loaded by LazyVim at the appropriate time

### Plugin Customization Pattern

Files in `lua/plugins/` either:
1. **Override** existing LazyVim plugins by returning a spec with the same plugin name — LazyVim merges them
2. **Add** new plugins not in LazyVim core

LazyVim extras are toggled in `lazyvim.json` (not in Lua files). Do not add extras in `lazy.lua` unless they need Lua-level configuration.

### Language Support Stack

**.NET/C#** (`lua/plugins/easy-dotnet.nvim.lua`, `after/ftplugin/cs.lua`):
- `easy-dotnet.nvim` handles LSP (Roslyn), debugger (netcoredbg via nvim-dap), test runner (VsTest via neotest), and formatting
- C# files use 4-space indentation (set in `after/ftplugin/cs.lua`)

**TypeScript** (via LazyVim extras `lang.typescript`):
- Uses `vtsls` language server and `biome` formatter/linter

**Database** (via LazyVim extra `util.sql`):
- vim-dadbod with DBUI — toggle with `<leader>D`
- MSSQL connections documented in `README.md`

### AI Integration

`lua/plugins/codecompanion.lua` — uses Claude Haiku 4.5 via a Copilot adapter (not direct Anthropic API). Requires Copilot authentication.

## Key Files

| File | Purpose |
|------|---------|
| `lazyvim.json` | Toggles LazyVim extras on/off |
| `lazy-lock.json` | Plugin version pins — commit to lock dependency versions |
| `lua/config/keymaps.lua` | All custom keybindings |
| `lua/config/options.lua` | Vim option overrides (currently minimal) |
| `lua/plugins/snacks.lua` | File picker, scratch pads, explorer customizations |
| `lua/plugins/nvim-dap.lua` | DAP adapters for .NET and JS/TS debugging |
| `lua/plugins/neotest.lua` | Test adapters (VsTest, Vitest, Jest) |

## Custom Keybindings (beyond LazyVim defaults)

| Key | Mode | Action |
|-----|------|--------|
| `jk` | insert | Escape |
| `<C-d>` / `<C-u>` | normal | Page scroll + center cursor |
| `yp` / `yP` | normal | Yank absolute/relative file path |
| `<leader>gd` | normal | Open diffview |
| `<leader>gq` | normal | Close diffview |
| `<leader>fl` | normal | Scratch todo list |
| `<leader>fL` | normal | Persistent TODO.md |

Snacks picker extras (active while picker is open):
- `<C-h>` / `<C-l>` — toggle focus list/preview
- `I` / `H` — toggle ignored/hidden files
- `A` — add new .NET item (in file explorer)

.NET buffer-local (`<leader>` prefix):
- `r` run test, `t` run all tests, `e` build errors, `d` debug test, `R` run all tests, `p` peek stack trace

## Adding Plugins

1. Create `lua/plugins/<name>.lua` returning a lazy.nvim spec table
2. Use `example.lua` as a reference template
3. Run `:Lazy sync` inside Neovim to install; `lazy-lock.json` will update — commit it

## Adding LazyVim Extras

Edit `lazyvim.json` directly (it is a JSON array of extra names). Run `:LazyExtras` inside Neovim for an interactive UI.
