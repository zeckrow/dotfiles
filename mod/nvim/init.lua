-- TREESITTER ===============================================================
vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		-- 1. Daftar filetype yang harus diabaikan
		local ignore_ft = { "TelescopePrompt", "TelescopeResults", "notify", "help", "qf" }
		for _, ft in ipairs(ignore_ft) do
			if args.match == ft then
				return
			end
		end

		local lang = vim.treesitter.language.get_lang(args.match) or args.match

		-- 2. Validasi apakah bahasa ini valid untuk Treesitter
		-- (Mencegah error jika FT aneh atau tidak ada parsernya di internet)
		if lang == "" or lang == nil then
			return
		end

		local ok, _ = pcall(vim.treesitter.language.inspect, lang)

		if not ok then
			-- Cek apakah modul nvim-treesitter sudah siap
			local ts_ok, ts = pcall(require, "nvim-treesitter")
			if ts_ok then
				-- Gunakan pcall lagi saat install agar jika gagal (misal internet mati)
				-- Neovim tidak crash/error prompt
				pcall(ts.install, lang, { sync = false })
			end
		end

		-- 3. Nyalakan highlight hanya jika bukan buffer Telescope
		pcall(vim.treesitter.start)
	end,
})
-- OPTIONS ===============================================================
local opt = vim.opt
opt.number = true -- Baris angka
opt.relativenumber = true -- Baris angka relatif (untuk navigasi cepat)
opt.cursorline = true -- Highlight baris kursor
opt.termguicolors = true -- Warna 24-bit
opt.signcolumn = "yes" -- Selalu tampilkan kolom ikon (LSP/Git)
opt.scrolloff = 10 -- Minimal 10 baris di atas/bawah kursor saat scroll
opt.tabstop = 2 -- Lebar tab
opt.shiftwidth = 2 -- Lebar indentasi
opt.expandtab = true -- Spasi sebagai tab
opt.smartindent = true -- Indentasi otomatis cerdas
opt.ignorecase = true -- Case-insensitive search
opt.smartcase = true -- Sensitive jika ada huruf kapital
opt.updatetime = 250 -- Delay update (milidetik)
opt.clipboard = "unnamedplus" -- Gunakan clipboard sistem
opt.mouse = "a" -- Aktifkan mouse
opt.undofile = true -- Simpan riwayat undo selamanya
opt.swapfile = false -- Jangan buat file swap
-- KEYMAPS ===============================================================
vim.g.mapleader = " " -- Spasi sebagai Leader
local keymap = vim.keymap.set
keymap("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap("n", "<leader>e", ":Ex<CR>", { desc = "Explorer" })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap("n", "<leader>x", ":bdelete<CR>", { desc = "Quit" })
keymap("i", "jk", "<Esc>", { desc = "Quit" })
keymap("n", "<Tab>", ":bnext<CR>")
keymap("n", "<S-Tab>", ":bprevious<CR>")
-- LSP ===============================================================
vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
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
-- enable lsp
vim.lsp.enable("lua_ls")
vim.lsp.enable("nixd")
-- COMPLETION AND SNIPPET ===============================================================
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
-- FORMATER ===============================================================
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
-- AUTOPAIRS ===============================================================
vim.pack.add({
	{ src = "https://github.com/windwp/nvim-autopairs" },
})
require("nvim-autopairs").setup({})

-- TELESCOPE ===============================================================
vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
-- COLORSCHEME ===============================================================

vim.pack.add({
	{ src = "https://github.com/gbprod/nord.nvim" },
})
-- Lua
vim.cmd.colorscheme("nord")
require("nord").setup({
	-- your configuration comes here
	-- or leave it empty to use the default settings
	transparent = true, -- Enable this to disable setting the background color
	terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
	diff = { mode = "bg" }, -- enables/disables colorful backgrounds when used in diff mode. values : [bg|fg]
	borders = true, -- Enable the border between verticaly split windows visible
	errors = { mode = "bg" }, -- Display mode for errors and diagnostics
	-- values : [bg|fg|none]
	search = { theme = "vim" }, -- theme for highlighting search results
	-- values : [vim|vscode]
	styles = {
		-- Style to be applied to different syntax groups
		-- Value is any valid attr-list value for `:help nvim_set_hl`
		comments = { italic = true },
		keywords = {},
		functions = {},
		variables = {},

		-- To customize lualine/bufferline
		bufferline = {
			current = {},
			modified = { italic = true },
		},

		lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
	},

	-- colorblind mode
	-- see https://github.com/EdenEast/nightfox.nvim#colorblind
	-- simulation mode has not been implemented yet.
	colorblind = {
		enable = false,
		preserve_background = false,
		severity = {
			protan = 0.0,
			deutan = 0.0,
			tritan = 0.0,
		},
	},
})
