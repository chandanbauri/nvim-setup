vim.g.python3_host_prog = vim.fn.expand("~/.pyenv/versions/3.11.9/bin/python3")
vim.g.perl_host_prog = vim.fn.expand("/usr/bin/perl")
-- Generate a unique filename for ShaDa
local shada_dir = vim.fn.stdpath("state") .. "/shada/"
local unique_shada_file = shada_dir .. "session_" .. os.time() .. "_" .. vim.fn.getpid() .. ".shada"

-- Ensure the directory exists
vim.fn.mkdir(shada_dir, "p")

-- Set the ShaDa file for the current session
vim.opt.shadafile = unique_shada_file

-- Define a function to delete the ShaDa file on exit
local function delete_shada_on_exit()
	vim.fn.delete(unique_shada_file)
end

-- Register an autocommand to delete the ShaDa file on VimLeave
vim.api.nvim_create_autocmd("VimLeave", {
	callback = delete_shada_on_exit,
})

require("sufu.plugins.telescope")
require("sufu.plugins-setup")
require("sufu.core.options")
require("sufu.core.keymaps")
require("sufu.core.colorscheme")
require("sufu.plugins.comment")
require("sufu.plugins.nvim-tree")
require("sufu.plugins.lualine")
require("sufu.plugins.fuzzy-finder")
require("sufu.plugins.live-server")
require("sufu.plugins.nvim-cmp")
require("sufu.plugins.lsp.mason")
require("sufu.plugins.lsp.lspsaga")
require("sufu.plugins.lsp.lspconfig")
-- require("sufu.plugins.lsp.null-ls") ** removed dependency as not maintained
require("sufu.plugins.ai")
require("sufu.plugins.avante")
require("sufu.plugins.mcp-hub")
require("sufu.plugins.lsp.nvim-lint")
require("sufu.plugins.autopairs")
require("sufu.plugins.autotag")
require("sufu.plugins.treesitter")
require("sufu.plugins.gitsigns")
require("sufu.plugins.icons")
require("sufu.plugins.copilot")
require("sufu.plugins.flutter")
require("sufu.plugins.bigfile-nvim")
