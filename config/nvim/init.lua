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
--::
--::disable auto comment on new line
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("no_auto_comment", {}),
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})
--::
--::cursor highlight
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client.server_capabilities.documentHighlightProvider then
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = args.buf,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = args.buf,
				callback = vim.lsp.buf.clear_references,
			})
		end
	end,
})
vim.opt.updatetime = 300
--::

--::keymaps
vim.g.mapleader = " "
local keymap = vim.keymap.set
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>e", ":Ex<CR>", { desc = "Explorer" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>x", ":bdelete<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>h", function()
	local is_enabled = vim.lsp.inlay_hint.is_enabled()
	vim.lsp.inlay_hint.enable(not is_enabled)
	local status = not is_enabled and "Dinyalakan" or "Dimatikan"
	print("Inlay Hints: " .. status)
end, { desc = "Toggle LSP Inlay Hints" })
keymap("i", "jk", "<Esc>", { desc = "Quit" })
keymap("n", "<Tab>", ":bnext<CR>")
keymap("n", "<S-Tab>", ":bprevious<CR>")
--::

--::lsp setup
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
})
require("mason").setup()

require("mason-tool-installer").setup({
	ensure_installed = {
		"lua-language-server",
		"rust-analyzer",
		"clangd",
	},
	integrations = {
		["mason-lspconfig"] = true,
	},
})

vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".git",
	},
	settings = {
		Lua = {
			hint = { enable = true },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
vim.lsp.enable("rust_analyzer")
--::

--::completion and snippets
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
})
require("luasnip.loaders.from_vscode").lazy_load()
require("blink.cmp").setup({
	fuzzy = { implementation = "prefer_rust_with_warning" },
	signature = { enabled = true },
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "normal",
	},
	completion = {
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
		},
	},

	cmdline = {
		keymap = {
			preset = "inherit",
			["<CR>"] = { "accept_and_enter", "fallback" },
		},
	},

	sources = { default = { "lsp", "path", "buffer", "snippets" } },
})
--::

--::formater
vim.pack.add({
	{ src = "https://github.com/stevearc/conform.nvim" },
})
require("conform").setup({
	format_on_save = {
		timeout_ms = 500,
		lsp_fallback = true,
	},
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "nixfmt" },
		json = { "jq" },
		rust = { "rustfmt" },
		python = { "black" },
		htmldjango = { "djlint" },
		html = { "djlint" },
		javascript = { "prettier" },
	},
})
--::

--::autopairs
vim.pack.add({
	{ src = "https://github.com/windwp/nvim-autopairs" },
})
require("nvim-autopairs").setup({})
--::

--::telecope
vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
--::

--::colorscheme
vim.pack.add({
	{ src = "https://github.com/rose-pine/neovim" },
})
vim.cmd.colorscheme("rose-pine")
--::

--::treesitter
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
})
require("rainbow-delimiters.setup").setup({})
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		-- 1. Daftar filetype yang harus diabaikan
		local ignore_ft = { "TelescopePrompt", "TelescopeResults", "notify", "help", "qf", "fidget" }
		for _, ft in ipairs(ignore_ft) do
			if args.match == ft then
				return
			end
		end
		local lang = vim.treesitter.language.get_lang(args.match) or args.match
		if lang == "" or lang == nil then
			return
		end
		local ok, _ = pcall(vim.treesitter.language.inspect, lang)
		if not ok then
			local ts_ok, ts = pcall(require, "nvim-treesitter")
			if ts_ok then
				pcall(ts.install, lang, { sync = false })
			end
		end
		pcall(vim.treesitter.start)
	end,
})
--::

--::
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
