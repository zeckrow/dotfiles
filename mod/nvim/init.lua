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
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
	settings = {
		Lua = {
			runtime = {
				version = "Lua 5.4",
			},
			completion = {
				enable = true,
			},
			diagnostics = {
				enable = true,
				globals = { "vim" },
			},
			workspace = {
				library = { vim.env.VIMRUNTIME },
				checkThirdParty = false,
			},
		},
	},
})

-- enable lsp
vim.lsp.enable("lua_ls")
vim.lsp.enable("nixd")

-- COMPLETION ===============================================================
vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("^1") },
})
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

	sources = { default = { "lsp", "path", "buffer" } },
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
-- TELESCOPE ===============================================================
vim.pack.add({
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
