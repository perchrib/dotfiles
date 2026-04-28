# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Learning notes for LazyVim and Neovim and related plugins

## Plugins

### VimDadbood `<leader>-D` - Toggle DBUI

This plugin is installed with lazy extra package name: `lang.sql`.

Connection string is in the format: `adapter://user:password@host:port/database`.

SQL Server (mssql):

Require: sqlcmd installed with brew.
The output from select query is not formatted well, this is a
known issue of sqlcmd, and the workaround within VimDadbood is
to set this in .zshrc:

```bash
export SQLCMDMAXVARTYPEWIDTH=30
export SQLCMDMAXFIXEDTYPEWIDTH=30
```

Example connection string for SQL Server:

* sqlserver://sa:Secret1234@localhost/TeksternDb
* sqlserver://sa:Secret1234@localhost:1433/TeksternDb?authentication=ActiveDirectoryDefault
  * Note: need to login in in terminal with `az login` first, and also need to have the Azure CLI installed with
