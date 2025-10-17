-- Modern LSP configuration using vim.lsp.config (Neovim 0.11+)
-- This replaces the deprecated require('lspconfig') approach

-- import cmp-nvim-lsp plugin safely for capabilities
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
  vim.notify("cmp-nvim-lsp not found", vim.log.levels.WARN)
  return
end

-- Setup LSPSaga FIRST before using it
local lspsaga_status, lspsaga = pcall(require, "lspsaga")
local has_lspsaga = false

if lspsaga_status then
  lspsaga.setup({
    ui = {
      theme = "round",
      border = "rounded",
      winblend = 0,
      expand = "",
      collapse = "",
      code_action = "💡",
      diagnostic = "🐞",
      hover = " ",
    },
    preview = {
      lines_above = 0,
      lines_below = 10,
    },
    scroll_preview = {
      scroll_down = "<C-f>",
      scroll_up = "<C-b>",
    },
    request_timeout = 2000,
    finder = {
      edit = { "o", "<CR>" },
      vsplit = "s",
      split = "i",
      tabe = "t",
      quit = { "q", "<ESC>" },
      max_height = 0.5,
      left_width = 0.4,
      methods = {
        tyd = "textDocument/typeDefinition",
      },
    },
    definition = {
      edit = "<C-c>o",
      vsplit = "<C-c>v",
      split = "<C-c>i",
      tabe = "<C-c>t",
      quit = "q",
      close = "<Esc>",
      width = 0.6,
      height = 0.6,
    },
    code_action = {
      num_shortcut = true,
      show_server_name = false,
      extend_gitsigns = true,
      only_in_cursor = false,
      keys = {
        quit = "q",
        exec = "<CR>",
      },
    },
    lightbulb = {
      enable = true,
      enable_in_insert = true,
      sign = true,
      sign_priority = 40,
      virtual_text = true,
    },
    diagnostic = {
      show_code_action = true,
      show_source = true,
      jump_num_shortcut = true,
      max_width = 0.7,
      max_height = 0.6,
      text_hl_follow = false,
      border_follow = true,
      keys = {
        exec_action = "o",
        quit = "q",
        expand_or_jump = "<CR>",
        quit_in_show = { "q", "<ESC>" },
      },
    },
    rename = {
      quit = "<C-c>",
      exec = "<CR>",
      mark = "x",
      confirm = "<CR>",
      in_select = true,
    },
    outline = {
      win_position = "right",
      win_with = "",
      win_width = 30,
      show_detail = true,
      auto_preview = true,
      auto_refresh = true,
      auto_close = true,
      custom_sort = nil,
      keys = {
        jump = "o",
        expand_collapse = "u",
        quit = "q",
      },
    },
    symbol_in_winbar = {
      enable = true,
      separator = " ",
      ignore_patterns = {},
      hide_keyword = true,
      show_file = true,
      folder_level = 2,
      respect_root = false,
      color_mode = true,
    },
    beacon = {
      enable = true,
      frequency = 7,
    },
    server_filetype_map = {},
    diagnostic_header = { " ", " ", " ", "ﴞ " },
  })
  has_lspsaga = true
else
  vim.notify("⚠️  LSPSaga not found, using native LSP commands", vim.log.levels.WARN)
end

local keymap = vim.keymap

-- Custom function to handle peek definition with proper window management
local function safe_peek_definition()
  vim.cmd("silent! Lspsaga close_floaterm")
  vim.defer_fn(function()
    vim.cmd("Lspsaga peek_definition")
  end, 10)
end

-- GENERAL LSP KEYBINDINGS (set globally when LSP is available)
local function setup_general_lsp_keybinds()
  local opts = { noremap = true, silent = true }

  -- General formatting and navigation
  keymap.set("n", "<leader>cff", "<cmd>lua vim.lsp.buf.format()<CR>", opts) -- format code
  keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)  -- go to implementation
  keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)     -- go to declaration

  if has_lspsaga then
    -- LSPSaga keybindings with safer implementations
    keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts)                         -- show definition, references
    keymap.set("n", "gd", safe_peek_definition, opts)                              -- see definition and make edits in window (safer)
    keymap.set("n", "<leader>gd", "<cmd>Lspsaga goto_definition<CR>", opts)        -- go to definition (alternative)
    keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)            -- see available code actions
    keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)                 -- smart rename
    keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)   -- show  diagnostics for line
    keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
    keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)           -- jump to previous diagnostic in buffer
    keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)           -- jump to next diagnostic in buffer
    keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)                       -- show documentation for what is under cursor
    keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts)                 -- see outline on right hand side
    keymap.set("n", "<leader>lc", "<cmd>Lspsaga close_floaterm<CR>", opts)         -- close all LSPSaga floating windows
  else
    -- Native LSP keybindings (fallback)
    keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.references()<CR>", opts)             -- show references
    keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)             -- go to definition
    keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)    -- see available code actions
    keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)         -- smart rename
    keymap.set("n", "<leader>D", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)   -- show diagnostics
    keymap.set("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)   -- show diagnostics for cursor
    keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)           -- jump to previous diagnostic in buffer
    keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)           -- jump to next diagnostic in buffer
    keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)                   -- show documentation for what is under cursor
    keymap.set("n", "<leader>o", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts) -- see outline/symbols
  end
end

-- Set up general keybindings immediately
setup_general_lsp_keybinds()

-- Get default capabilities from cmp-nvim-lsp
local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- Language-specific on_attach functions for custom keybindings

-- TypeScript/JavaScript specific on_attach
local function on_attach_typescript(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- TypeScript specific keymaps
  keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>", opts)      -- rename file and update imports
  keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>", opts) -- organize imports
  keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>", opts)    -- remove unused variables

  vim.notify("TypeScript LSP attached with specific keybindings", vim.log.levels.INFO)
end

-- Rust specific on_attach
local function on_attach_rust(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Rust specific features
  if client.server_capabilities.inlayHintProvider then
    -- vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  vim.notify("Rust LSP attached with specific features", vim.log.levels.INFO)
end

-- Python specific on_attach
local function on_attach_python(client, bufnr)
  vim.notify("Python LSP attached", vim.log.levels.INFO)
end

-- PHP specific on_attach
local function on_attach_php(client, bufnr)
  vim.notify("PHP LSP attached", vim.log.levels.INFO)
end

-- Lua specific on_attach
local function on_attach_lua(client, bufnr)
  vim.notify("Lua LSP attached", vim.log.levels.INFO)
end

-- Generic on_attach for web development LSPs
local function on_attach_web(client, bufnr)
  vim.notify(client.name .. " LSP attached", vim.log.levels.INFO)
end

-- Helper function to check if executable exists
local function executable_exists(name)
  return vim.fn.executable(name) == 1
end

-- Helper function to merge on_attach callbacks
local function create_on_attach(custom_on_attach)
  return function(client, bufnr)
    -- Call custom on_attach if provided
    if custom_on_attach then
      custom_on_attach(client, bufnr)
    end
  end
end

-- Configure LSP servers using vim.lsp.config
-- The configs from ~/.config/nvim/lsp/*.lua are automatically loaded

-- TypeScript/JavaScript
if executable_exists("typescript-language-server") then
  vim.lsp.config("ts_ls", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_typescript),
  })
  vim.lsp.enable("ts_ls")
end

-- Lua
if executable_exists("lua-language-server") then
  vim.lsp.config("lua_ls", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_lua),
  })
  vim.lsp.enable("lua_ls")
end

-- Rust
if executable_exists("rust-analyzer") then
  vim.lsp.config("rust_analyzer", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_rust),
  })
  vim.lsp.enable("rust_analyzer")
end

-- Python
if executable_exists("pyright") then
  vim.lsp.config("pyright", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_python),
  })
  vim.lsp.enable("pyright")
end

-- PHP
if executable_exists("intelephense") then
  vim.lsp.config("intelephense", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_php),
  })
  vim.lsp.enable("intelephense")
end

-- Web development LSPs (HTML, CSS, Tailwind, Emmet)
if executable_exists("vscode-html-language-server") then
  vim.lsp.config("html", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_web),
  })
  vim.lsp.enable("html")
end

if executable_exists("vscode-css-language-server") then
  vim.lsp.config("cssls", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_web),
  })
  vim.lsp.enable("cssls")
end

if executable_exists("tailwindcss-language-server") then
  vim.lsp.config("tailwindcss", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_web),
  })
  vim.lsp.enable("tailwindcss")
end

if executable_exists("emmet-ls") then
  vim.lsp.config("emmet_ls", {
    capabilities = capabilities,
    on_attach = create_on_attach(on_attach_web),
  })
  vim.lsp.enable("emmet_ls")
end

-- Debug commands
vim.api.nvim_create_user_command("LspStatus", function()
  print("LSPSaga available: " .. tostring(has_lspsaga))
  local clients = vim.lsp.get_clients()
  print("Active LSP clients:")
  for _, client in ipairs(clients) do
    print("  - " .. client.name .. " (id: " .. client.id .. ")")
  end

  -- Check for potential conflicts
  local bufnr = vim.api.nvim_get_current_buf()
  local buffer_clients = vim.lsp.get_clients({ bufnr = bufnr })
  if #buffer_clients > 1 then
    print("⚠️  Multiple LSP clients attached to current buffer:")
    for _, client in ipairs(buffer_clients) do
      print("    - " .. client.name)
    end
    print("This might cause double floating windows. Consider using :LspRestart")
  end
end, { desc = "Show LSP status and active clients" })

-- Add command to restart LSP
vim.api.nvim_create_user_command("LspRestart", function()
  vim.cmd("LspStop")
  vim.defer_fn(function()
    vim.cmd("LspStart")
    vim.notify("LSP restarted", vim.log.levels.INFO)
  end, 1000)
end, { desc = "Restart LSP clients" })

-- Add command to close all floating windows
vim.api.nvim_create_user_command("LspCloseAll", function()
  -- Close LSPSaga windows
  if has_lspsaga then
    pcall(function() vim.cmd("Lspsaga close_floaterm") end)
  end

  -- Close any other floating windows
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      pcall(function() vim.api.nvim_win_close(win, false) end)
    end
  end

  vim.notify("All floating windows closed", vim.log.levels.INFO)
end, { desc = "Close all floating windows" })
