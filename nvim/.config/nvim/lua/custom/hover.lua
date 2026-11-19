-- Everything K (hover) does beyond the default, wired up in lua/plugins/lsp.lua:
--
-- 1. SVG icon preview: if the variable under the cursor is an SVG string, e.g. from an icon library:
--      declare const trashcanExpressiveIcon = "<svg viewBox=\"0 0 24 24\" ...>...</svg>";
--    render it to a PNG with ImageMagick and show it in a small float under the cursor instead of the
--    hover (snacks.nvim draws it). K again shows the normal hover; moving the cursor closes the icon.
--    Requires Inkscape: ImageMagick hands SVGs to it when installed, and that is what makes
--    fill="currentColor" render (ImageMagick's built-in SVG renderer leaves those icons blank).
--
-- 2. Roslyn hover fix (C#): Roslyn escapes punctuation in its hover markdown (\< \> \. \-).
--    noice hides the backslash only for some characters and hides \< and \> completely, so
--    List<string> showed up as Liststring. The escapes are removed before anything displays it.
local M = {}

local cache_dir = vim.fn.stdpath("cache") .. "/svg-icon-preview"
local size = 256

-- Only look for icons in these filetypes
M.filetypes = {
	svelte = true,
	typescript = true,
	typescriptreact = true,
	javascript = true,
	javascriptreact = true,
	html = true,
}

local icon_win -- the float showing the icon
local augroup = vim.api.nvim_create_augroup("custom_hover_icon", { clear = true })

--- Find `name = "<svg ...</svg>"` in a line and unescape \" to "
local function extract(line, name)
	local first
	for n, svg in line:gmatch('([%w_$]+)%s*=%s*"(<svg.-</svg>)"') do
		local icon = { name = n, svg = (svg:gsub('\\"', '"')) }
		if n == name then
			return icon
		end
		first = first or icon
	end
	return first
end

--- Make the SVG work as a standalone file: fixed size on the root <svg> (1em renders tiny), plus xmlns
local function standalone(svg)
	local open, rest = svg:match("^(<svg[^>]*>)(.*)$")
	if not open then
		return svg
	end
	open = open:gsub('%s+width="[^"]*"', ""):gsub('%s+height="[^"]*"', "")
	if not open:find("xmlns=", 1, true) then
		open = open:gsub("^<svg", '<svg xmlns="http://www.w3.org/2000/svg"')
	end
	open = open:gsub("^<svg", ('<svg width="%d" height="%d"'):format(size, size))
	return open .. rest
end

--- Render to a cached PNG; the hash changes when the icon changes, so stale previews are never shown
local function render(icon)
	local png = ("%s/%s-%s.png"):format(cache_dir, icon.name, vim.fn.sha256(icon.svg):sub(1, 12))
	if vim.uv.fs_stat(png) then
		return png
	end
	if vim.fn.executable("magick") == 0 then
		vim.notify("ImageMagick (magick) not found", vim.log.levels.ERROR, { title = "SVG preview" })
		return
	end
	vim.fn.mkdir(cache_dir, "p")
	local svg = ("%s/%s.svg"):format(cache_dir, icon.name)
	vim.fn.writefile({ standalone(icon.svg) }, svg)
	-- White background: currentColor renders black, which would vanish on a dark background
	local res = vim.system({ "magick", svg, "-background", "white", "-alpha", "remove", png }, { text = true }):wait()
	if res.code ~= 0 then
		vim.notify("magick failed:\n" .. (res.stderr or ""), vim.log.levels.ERROR, { title = "SVG preview" })
		return
	end
	return png
end

local function close_icon()
	vim.api.nvim_clear_autocmds({ group = augroup })
	if icon_win and vim.api.nvim_win_is_valid(icon_win) then
		local buf = vim.api.nvim_win_get_buf(icon_win)
		vim.api.nvim_win_close(icon_win, true)
		pcall(vim.api.nvim_buf_delete, buf, { force = true })
	end
	icon_win = nil
end

--- Show the png in a small float under the cursor. The cursor stays where it is.
local function show_icon(png)
	close_icon()
	local src = vim.api.nvim_get_current_buf()
	local buf = vim.fn.bufadd(png)
	vim.bo[buf].buflisted = false
	-- Opening the window loads the png, and snacks.nvim takes over image files and draws them
	icon_win = vim.api.nvim_open_win(buf, false, {
		relative = "cursor",
		row = 1,
		col = 0,
		-- terminal cells are about twice as tall as wide, so 24x12 is roughly square
		width = 24,
		height = 12,
		style = "minimal",
		border = "rounded",
		focusable = false,
	})
	-- Close it when the cursor moves, like the hover (scheduled so the K press itself doesn't close it)
	vim.schedule(function()
		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufLeave" }, {
			group = augroup,
			buffer = src,
			callback = close_icon,
		})
	end)
end

--- Use "go to definition" to find the SVG string behind the variable `name` under the cursor
local function find_icon(name)
	local params = vim.lsp.util.make_position_params(0, "utf-16")
	local results = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 500)
	for _, res in pairs(results or {}) do
		local locs = res.result
		if locs and not vim.islist(locs) then
			locs = { locs }
		end
		for _, loc in ipairs(locs or {}) do
			local uri = loc.uri or loc.targetUri
			local range = loc.targetSelectionRange or loc.range or loc.targetRange
			if uri and range and vim.startswith(uri, "file://") then
				local lnum = range.start.line + 1
				-- read only up to the definition line, not the whole icon library
				local ok, lines = pcall(vim.fn.readfile, vim.uri_to_fname(uri), "", lnum)
				local icon = ok and extract(lines[lnum] or "", name)
				if icon then
					return icon
				end
			end
		end
	end
end

-- Filetypes served by Roslyn, whose hover replies get unescaped
M.roslyn_filetypes = {
	cs = true,
	razor = true,
}

--- Wrap the client's request function so hover replies come back with \< \> \. \- etc. as plain characters.
--- Done once per client; it then applies to every hover from that client.
local function unescape_hover(client)
	if client._unescape_hover then
		return
	end
	client._unescape_hover = true
	local request = client.request
	client.request = function(self, method, params, handler, ...)
		if method == "textDocument/hover" and handler then
			local orig = handler
			handler = function(err, result, ...)
				local c = result and result.contents
				if type(c) == "table" and type(c.value) == "string" then
					c.value = c.value:gsub("\\(%p)", "%1")
				end
				return orig(err, result, ...)
			end
		end
		return request(self, method, params, handler, ...)
	end
end

--- K: show the SVG icon (if any) / fix Roslyn's escapes and show the normal hover.
--- On an icon, K shows the icon instead of the hover; K again closes it and shows the hover.
function M.hover()
	if icon_win and vim.api.nvim_win_is_valid(icon_win) then
		close_icon()
	elseif M.filetypes[vim.bo.filetype] then
		local icon = find_icon(vim.fn.expand("<cword>"))
		local png = icon and render(icon)
		if png then
			return show_icon(png)
		end
	elseif M.roslyn_filetypes[vim.bo.filetype] then
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" })) do
			unescape_hover(client)
		end
	end
	vim.lsp.buf.hover()
end

return M
