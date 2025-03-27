local lsp_zero_status, lsp_zero = pcall(require, "lsp-zero")
if not lsp_zero_status then
	return
end
-- import mason plugin safely
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	return
end

-- import mason-lspconfig plugin safely
local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status then
	return
end

-- import mason-null-ls plugin safely
-- local mason_null_ls_status, mason_null_ls = pcall(require, "mason-null-ls")
-- if not mason_null_ls_status then
-- 	return
-- end

-- enable mason
mason.setup()

mason_lspconfig.setup({
	ensure_installed = {
		"ts_ls", -- TypeScript/JavaScript
		"html", -- HTML
		"cssls", -- CSS
		"tailwindcss", -- Tailwind CSS
		"lua_ls", -- Lua
		"emmet_ls", -- Emmet
		"rust_analyzer", -- Rust
		"pyright", -- Python
		"eslint", -- ESLint
		"gradle_ls", -- Gradle
		"vimls", -- Vim
	},
	-- handlers = {
	-- 	function(server_name) -- Default handler (optional)
	-- 		local capabilities = require("cmp_nvim_lsp").default_capabilities()
	--     if server_name == "tsserver" then
	--         server_name = "ts_ls"
	--     end
	-- 		lsp_zero.default_setup(server_name)
	--   end
	-- },
	automatic_installation = true, -- not the same as ensure_installed
})

-- mason_null_ls.setup({
-- 	ensure_installed = {
-- 		"prettier", -- Formatter for TypeScript/JavaScript
-- 		"stylua", -- Lua formatter
-- 		"eslint_d", -- Linter for JavaScript/TypeScript
-- 		"black", -- Python formatter
-- 		"shfmt", -- Shell script formatter
-- 		"rustfmt", -- Rust formatter
-- 		"flake8", -- Python linter
-- 		"shellcheck", -- Shell script linter
-- 	},
-- 	automatic_installation = true,
-- })
