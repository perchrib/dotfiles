-- appsettings.json in dotnet projects is set to json5, so we need to override it to json to get proper syntax highlighting and linting.
-- Any buffer detected as json5 should really be json
vim.bo.filetype = "json"
