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

local mason_nvim_lint_status, mason_nvim_lint = pcall(require, "mason-nvim-lint")
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
    "ts_ls",       -- TypeScript/JavaScript
    "html",        -- HTML
    "cssls",       -- CSS
    "tailwindcss", -- Tailwind CSS
    "lua_ls",      -- Lua
    "emmet_ls",    -- Emmet
    "rust_analyzer", -- Rust
    "pyright",     -- Python
    "eslint",      -- ESLint
    "gradle_ls",   -- Gradle
    "vimls",       -- Vim
  },
  automatic_installation = true,
  -- handlers = {
  -- 	function(server_name) -- Default handler (optional)
  -- 		local capabilities = require("cmp_nvim_lsp").default_capabilities()
  --     if server_name == "tsserver" then
  --         server_name = "ts_ls"
  --     end
  -- 		lsp_zero.default_setup(server_name)
  --   end
  -- },
 -- not the same as ensure_installed
})

require("mason-nvim-lint").setup({
  ensure_installed = {
    -- "php-cs-fixer",
  },
  automatic_installation = true
})

