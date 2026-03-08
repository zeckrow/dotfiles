--:: options
local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 10
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 250
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.undofile = true
opt.swapfile = false
--::keymaps
vim.g.mapleader = " "
local keymap = vim.keymap.set
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>e", ":Ex<CR>", { desc = "Explorer" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>x", ":bdelete<CR>", { desc = "Quit" })
keymap("i", "jk", "<Esc>", { desc = "Quit" })
keymap("n", "<Tab>", ":bnext<CR>")
keymap("n", "<S-Tab>", ":bprevious<CR>")
keymap("n", "<leader>h", ":lua vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())<CR>")

--::
--::floating terminal
local term_buf = nil
local term_win = nil
function _G.toggle_bottom_terminal()
	if term_win and vim.api.nvim_win_is_valid(term_win) then
		vim.api.nvim_win_hide(term_win)
		term_win = nil
		return
	end
	if term_buf == nil or not vim.api.nvim_buf_is_valid(term_buf) then
		term_buf = vim.api.nvim_create_buf(false, true)
	end
	local stats = vim.api.nvim_list_uis()[1]
	local padding = 1
	local width = stats.width - (padding * 4) -- Hampir selebar layar
	local height = 12
	local row = stats.height - height - 3
	local col = padding * 2
	local opts = {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		title = "  Terminal ",
		title_pos = "left",
	}
	term_win = vim.api.nvim_open_win(term_buf, true, opts)
	if vim.bo[term_buf].buftype ~= "terminal" then
		vim.cmd("terminal")
		vim.bo[term_buf].buflisted = false
	end
	vim.cmd("startinsert")
end

vim.keymap.set({ "n", "t" }, "<leader>t", "<CMD>lua toggle_bottom_terminal()<CR>", { noremap = true, silent = true })
--:

--::disable auto comment on new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})
--:: hightlight cursor
vim.api.nvim_set_hl(0, "SearchMatch", { bg = "#3e4452", fg = "NONE", underline = true })
local highlight_group = vim.api.nvim_create_augroup("BufferHighlight", { clear = true })
vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
	group = highlight_group,
	callback = function()
		if vim.w.current_match_id then
			pcall(vim.fn.matchdelete, vim.w.current_match_id)
			vim.w.current_match_id = nil
		end
		local word = vim.fn.expand("<cword>")
		if word ~= "" and word:match("^[a-zA-Z0-9_]+$") then
			-- Gunakan pola regex agar hanya kata yang pas yang kena highlight
			local pattern = [[\<]] .. word .. [[\>]]
			-- Terapkan highlight ke seluruh buffer
			vim.w.current_match_id = vim.fn.matchadd("SearchMatch", pattern, -1)
		end
	end,
})
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	group = highlight_group,
	callback = function()
		if vim.w.current_match_id then
			pcall(vim.fn.matchdelete, vim.w.current_match_id)
			vim.w.current_match_id = nil
		end
	end,
})

--: auto pairs
-- ==========================================================================
-- FINAL MINIMALIST AUTO PAIRS (NO PLUGINS)
-- Fixed: Triple Quotes, Inside Brackets Delete, and Skip-Over
-- ==========================================================================

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Tabel pasangan karakter
local char_pairs = {
	["("] = ")",
	["["] = "]",
	["{"] = "}",
	['"'] = '"',
	["'"] = "'",
	["`"] = "`",
}

-- 1. Logic: Auto Insert & Skip-Over
for open, close in pairs(char_pairs) do
	keymap("i", open, function()
		local line = vim.api.nvim_get_current_line()
		local col = vim.api.nvim_win_get_cursor(0)[2] -- 0-indexed
		local char_before = line:sub(col, col)
		local char_after = line:sub(col + 1, col + 1)

		-- Handle Skip-Over: Jika karakter di depan sudah sama dengan penutup
		if char_after == close then
			-- Khusus kutip: JANGAN skip jika ingin buat triple quotes (misal: "" -> """)
			if open == close and char_before == open then
				return open .. close .. "<Left>"
			end
			-- Selain itu, lompati karakter di depan
			return "<Right>"
		end

		-- Normal Auto Pair: Masukkan pasangan dan geser kursor ke tengah
		return open .. close .. "<Left>"
	end, { expr = true, noremap = true })
end

-- 2. Logic: Smart Backspace (Hapus pasangan sekaligus)
keymap("i", "<BS>", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local char_before = line:sub(col, col)
	local char_after = line:sub(col + 1, col + 1)

	-- Jika kursor berada tepat di tengah pasangan, hapus keduanya
	if char_pairs[char_before] and char_pairs[char_before] == char_after then
		return "<BS><Del>"
	end

	return "<BS>"
end, { expr = true, noremap = true })

-- 3. Logic: Smart Enter (New line dengan indentasi otomatis)
keymap("i", "<CR>", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]

	local char_before = line:sub(col, col)
	local char_after = line:sub(col + 1, col + 1)

	-- Berlaku untuk kurung (), [], dan {}
	local openers = { ["("] = ")", ["["] = "]", ["{"] = "}" }
	if openers[char_before] == char_after then
		return "<CR><Esc>O"
	end

	return "<CR>"
end, { expr = true, noremap = true })
--: tab
-- Selalu tampilkan tabline
vim.opt.showtabline = 2
function _G.SimpleTabLine()
	local s = ""
	local bufs = vim.api.nvim_list_bufs()
	local current = vim.api.nvim_get_current_buf()
	local index = 1

	for _, bufnr in ipairs(bufs) do
		if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, "buflisted") then
			local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
			if name == "" then
				name = "[No Name]"
			end

			if bufnr == current then
				-- Pakai background abu-abu untuk yang aktif
				s = s .. "%#ActiveTab# " .. index .. ":" .. name .. " "
			else
				-- Teks biasa untuk yang tidak aktif
				s = s .. "%#InactiveTab# " .. index .. ":" .. name .. " "
			end
			index = index + 1
		end
	end
	return s .. "%#TabLineFill#"
end

vim.opt.tabline = "%!v:lua.SimpleTabLine()"

vim.cmd([[
  highlight ActiveTab guifg=#ffffff guibg=#444444 gui=bold
  highlight InactiveTab guifg=#888888 guibg=NONE
  highlight TabLineFill guibg=NONE
]])

--=============Custom==============
-- color scheme
vim.pack.add({
	{ src = "https://github.com/rose-pine/neovim" },
})
vim.cmd("colorscheme rose-pine")

-- formater
vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/saghen/blink.cmp", version = "v1.5.0" },
})
require("blink.cmp").setup({
	keymap = { preset = "default" },
	completion = {
		menu = {
			draw = {
				-- Kita tambahkan 'source_name' di kolom paling kanan
				columns = {
					{ "label", "label_description", gap = 1 },
					{ "kind_icon", "source_name", gap = 1 },
				},
			},
		},
	},
	-- Default list of enabled providers defined so that you can extend it
	-- elsewhere in your config, without redefining it, due to `opts_extend`
	sources = {
		default = { "buffer", "path", "snippets", "lsp" },
		providers = {
			buffer = {
				score_offset = 100, -- Naikkan angka ini agar buffer lebih diprioritaskan
				min_keyword_length = 2, -- Mulai muncul setelah ketik 2 karakter
			},
		},
	},
})
require("mason").setup()
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		-- Conform will run multiple formatters sequentially
		python = { "isort", "black" },
		-- You can customize some of the format options for the filetype (:help conform.format)
		rust = { "rustfmt", lsp_format = "fallback" },
		-- Conform will run the first available formatter
		javascript = { "prettierd", "prettier", stop_after_first = true },
	},
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})
--:lsp
vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
--: diagnostic custom
local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = "󰋽 " }

-- 3. Konfigurasi Diagnostic (Cara Modern)
vim.diagnostic.config({
	virtual_text = false, -- Matikan teks di samping agar tidak berantakan
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = signs.Error,
			[vim.diagnostic.severity.WARN] = signs.Warn,
			[vim.diagnostic.severity.HINT] = signs.Hint,
			[vim.diagnostic.severity.INFO] = signs.Info,
		},
	},
	update_in_insert = false,
	underline = true,
	severity_sort = true,
	float = {
		focused = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})
vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, {
			focusable = false,
			close_events = { "BufLeave", "CursorMoved", "InsertEnter" },
			border = "rounded", -- Kotak rounded agar estetik
			source = "always", -- Menampilkan sumber error (misal: rust-analyzer)
			prefix = " ",
		})
	end,
})
vim.opt.updatetime = 100
--: telescope
vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
