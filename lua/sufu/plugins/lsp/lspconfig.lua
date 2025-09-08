-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
  return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
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
      -- Prevent multiple windows
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
    -- Additional settings to prevent multiple windows
    server_filetype_map = {},
    diagnostic_header = { " ", " ", " ", "ﴞ " },
  })
  has_lspsaga = true
else
  vim.notify("⚠️  LSPSaga not found, using native LSP commands", vim.log.levels.WARN)
end

local keymap = vim.keymap -- for conciseness

-- Track which LSPs have been loaded to prevent duplicates
local loaded_lsps = {}

-- Helper function to check if executable exists
local function executable_exists(name)
  return vim.fn.executable(name) == 1
end

-- Helper function to setup LSP only once
local function setup_lsp_once(lsp_name, setup_function)
  if not loaded_lsps[lsp_name] then
    setup_function()
    loaded_lsps[lsp_name] = true
    -- Disable rustowl if setting up rust_analyzer
    if lsp_name == "rust_analyzer" then
      pcall(function()
        lspconfig.rustowl = nil
      end)
    end
  end
end

-- Custom function to handle peek definition with proper window management
local function safe_peek_definition()
  -- Close any existing LSPSaga windows first
  vim.cmd("silent! Lspsaga close_floaterm")
  -- Small delay to ensure cleanup
  vim.defer_fn(function()
    vim.cmd("Lspsaga peek_definition")
  end, 10)
end

-- GENERAL LSP KEYBINDINGS (set globally when LSP is available)
local function setup_general_lsp_keybinds()
  local opts = { noremap = true, silent = true }

  -- General formatting and navigation
  keymap.set("n", "<leader>cff", "<cmd>lua vim.lsp.buf.format()<CR>", opts)      -- format code
  keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)       -- go to implementation
  keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)          -- go to declaration

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
    
    -- Additional keybinding to force close all LSPSaga windows
    keymap.set("n", "<leader>lc", "<cmd>Lspsaga close_floaterm<CR>", opts)         -- close all LSPSaga floating windows
  else
    -- Native LSP keybindings (fallback)
    keymap.set("n", "gf", "<cmd>lua vim.lsp.buf.references()<CR>", opts)           -- show references
    keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)           -- go to definition
    keymap.set("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)  -- see available code actions
    keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)       -- smart rename
    keymap.set("n", "<leader>D", "<cmd>lua vim.diagnostic.open_float()<CR>", opts) -- show diagnostics
    keymap.set("n", "<leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>", opts) -- show diagnostics for cursor
    keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)         -- jump to previous diagnostic in buffer
    keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)         -- jump to next diagnostic in buffer
    keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)                 -- show documentation for what is under cursor
    keymap.set("n", "<leader>o", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", opts) -- see outline/symbols
  end
end

-- Set up general keybindings immediately
setup_general_lsp_keybinds()

local capabilities = cmp_nvim_lsp.default_capabilities()

-- Change the Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

-- INDIVIDUAL ON_ATTACH FUNCTIONS FOR EACH LSP SERVER

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
  
  -- Rust specific features (you can add more Rust-specific keybindings here)
  if client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  
  -- Example: Add Rust-specific keybindings
  -- keymap.set("n", "<leader>rc", ":RustRunnables<CR>", opts)  -- run cargo commands
  -- keymap.set("n", "<leader>rt", ":RustTest<CR>", opts)       -- run tests
  
  vim.notify("Rust LSP attached with specific features", vim.log.levels.INFO)
end

-- Python specific on_attach
local function on_attach_python(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- Python specific keybindings (add as needed)
  -- keymap.set("n", "<leader>pi", ":PythonImports<CR>", opts)  -- organize imports
  -- keymap.set("n", "<leader>pt", ":PythonTest<CR>", opts)     -- run tests
  
  vim.notify("Python LSP attached", vim.log.levels.INFO)
end

-- PHP specific on_attach
local function on_attach_php(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- PHP specific keybindings (add as needed)
  -- keymap.set("n", "<leader>pf", ":PhpFormat<CR>", opts)      -- PHP specific formatting
  
  vim.notify("PHP LSP attached", vim.log.levels.INFO)
end

-- Lua specific on_attach
local function on_attach_lua(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  
  -- Lua specific keybindings (add as needed)
  -- keymap.set("n", "<leader>lf", ":LuaFormat<CR>", opts)      -- Lua specific formatting
  
  vim.notify("Lua LSP attached", vim.log.levels.INFO)
end

-- Generic on_attach for web development LSPs (HTML, CSS, etc.)
local function on_attach_web(client, bufnr)
  -- These LSPs typically don't need specific keybindings beyond the general ones
  vim.notify(client.name .. " LSP attached", vim.log.levels.INFO)
end

-- Project type constants
local project_types = {
  node = "Node",
  python = "Python",
  rust = "Rust",
  php = "Php"
}

-- Detect project type based on project files
local function detect_project_type()
  local cwd = vim.fn.getcwd()
  local project_type = ""

  if vim.fn.filereadable(cwd .. "/package.json") == 1 then
    project_type = project_types.node
  end

  if vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
    project_type = project_types.rust
  end

  if vim.fn.filereadable(cwd .. "/requirements.txt") == 1 or 
     vim.fn.filereadable(cwd .. "/pyproject.toml") == 1 then
    project_type = project_types.python
  end

  if vim.fn.filereadable(cwd .. "/composer.json") == 1 then
    project_type = project_types.php
  end

  return project_type
end

-- LSP setup functions with specific on_attach functions
local function set_node_lsp() 
  if not executable_exists("typescript-language-server") then 
    vim.notify("typescript-language-server not found", vim.log.levels.WARN)
    return 
  end
  lspconfig["ts_ls"].setup({
    capabilities = capabilities,
    on_attach = on_attach_typescript,
  })
end

local function set_lua_ls() 
  if not executable_exists("lua-language-server") then 
    vim.notify("lua-language-server not found", vim.log.levels.WARN)
    return 
  end
  lspconfig["lua_ls"].setup({
    capabilities = capabilities,
    on_attach = on_attach_lua,
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.stdpath("config") .. "/lua"] = true,
          },
        },
      },
    },
  })
end

local function set_rust_lsp()
  if not executable_exists("rust-analyzer") then 
    vim.notify("rust-analyzer not found", vim.log.levels.WARN)
    return 
  end
  
  lspconfig["rust_analyzer"].setup({
    capabilities = capabilities,
    on_attach = on_attach_rust,
    cmd = {
      "rustup",
      "run",
      "stable", 
      "rust-analyzer",
    },
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
          loadOutDirsFromCheck = true,
          buildScripts = {
            enable = true,
          },
        },
        procMacro = {
          enable = true,
          attributes = {
            enable = true,
          },
        },
        diagnostics = {
          enable = true,
          enableExperimental = true,
        },
        check = {
          command = "clippy",
          extraArgs = { "--no-deps" },
          allFeatures = true,
          allTargets = true,
        },
        completion = {
          autoimport = {
            enable = true,
          },
          callable = {
            snippets = "fill_arguments",
          },
        },
        imports = {
          merge = {
            blob = true,
          },
          prefix = "crate",
          group = {
            enable = true,
          },
        },
        inlayHints = {
          chainingHints = {
            enable = true,
          },
          closingBraceHints = {
            enable = true,
            minLines = 25,
          },
          parameterHints = {
            enable = true,
          },
          typeHints = {
            enable = true,
          },
        },
        lens = {
          enable = true,
          debug = {
            enable = true,
          },
          implementations = {
            enable = true,
          },
          run = {
            enable = true,
          },
        },
      },
    },
  })
end

local function set_pyright()
  if not executable_exists("pyright") then 
    vim.notify("pyright not found", vim.log.levels.WARN)
    return 
  end
  lspconfig["pyright"].setup({
    capabilities = capabilities,
    on_attach = on_attach_python,
  })
end

local function set_php_lsp() 
  if not executable_exists("intelephense") then 
    vim.notify("intelephense not found", vim.log.levels.WARN)
    return 
  end
  lspconfig["intelephense"].setup({
    capabilities = capabilities,
    on_attach = on_attach_php,
    settings = {
      intelephense = {
        format = {
          enable = true,
        },
        files = {
          maxSize = 5000000,
        },
      },
    },
  })
end

-- Always-on LSPs (web development essentials)
local function setup_web_lsps()
  -- HTML
  if executable_exists("vscode-html-language-server") then
    lspconfig["html"].setup({
      capabilities = capabilities,
      on_attach = on_attach_web,
    })
    loaded_lsps["html"] = true
  end

  -- CSS
  if executable_exists("vscode-css-language-server") then
    lspconfig["cssls"].setup({
      capabilities = capabilities,
      on_attach = on_attach_web,
    })
    loaded_lsps["cssls"] = true
  end

  -- Tailwind CSS
  if executable_exists("tailwindcss-language-server") then
    lspconfig["tailwindcss"].setup({
      capabilities = capabilities,
      on_attach = on_attach_web,
    })
    loaded_lsps["tailwindcss"] = true
  end

  -- Emmet
  lspconfig["emmet_ls"].setup({
    capabilities = capabilities,
    on_attach = on_attach_web,
    filetypes = {
      "html",
      "typescriptreact",
      "javascriptreact",
      "css",
      "sass",
      "scss",
      "less",
      "svelte",
      "ejs",
      "php",
    },
  })
  loaded_lsps["emmet_ls"] = true
end

-- Detect project type and load primary LSPs
local project_type = detect_project_type()

if project_type == project_types.node then
  setup_lsp_once("ts_ls", set_node_lsp)
end

if project_type == project_types.rust then
  setup_lsp_once("rust_analyzer", set_rust_lsp)
end

if project_type == project_types.python then
  setup_lsp_once("pyright", set_pyright)
end

if project_type == project_types.php then
  setup_lsp_once("intelephense", set_php_lsp)
end

-- Setup web development LSPs (always load these)
setup_web_lsps()

-- Create autocommand group for filetype-based loading
local lsp_group = vim.api.nvim_create_augroup("LSPFiletypeSetup", { clear = true })

-- Filetype-based autocommands for additional LSPs
vim.api.nvim_create_autocmd("FileType", {
  group = lsp_group,
  pattern = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
  callback = function()
    setup_lsp_once("ts_ls", set_node_lsp)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = lsp_group,
  pattern = "rust",
  callback = function()
    setup_lsp_once("rust_analyzer", set_rust_lsp)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = lsp_group,
  pattern = "python",
  callback = function()
    setup_lsp_once("pyright", set_pyright)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = lsp_group,
  pattern = "php",
  callback = function()
    setup_lsp_once("intelephense", set_php_lsp)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = lsp_group,
  pattern = "lua",
  callback = function()
    setup_lsp_once("lua_ls", set_lua_ls)
  end,
})

-- Optional: Add a command to manually load specific LSPs
vim.api.nvim_create_user_command("LspLoad", function(opts)
  local lsp_name = opts.args
  if lsp_name == "node" or lsp_name == "typescript" then
    setup_lsp_once("ts_ls", set_node_lsp)
  elseif lsp_name == "rust" then
    setup_lsp_once("rust_analyzer", set_rust_lsp)
  elseif lsp_name == "python" then
    setup_lsp_once("pyright", set_pyright)
  elseif lsp_name == "php" then
    setup_lsp_once("intelephense", set_php_lsp)
  elseif lsp_name == "lua" then
    setup_lsp_once("lua_ls", set_lua_ls)
  else
    vim.notify("Unknown LSP: " .. lsp_name, vim.log.levels.ERROR)
  end
end, {
  nargs = 1,
  complete = function()
    return { "node", "typescript", "rust", "python", "php", "lua" }
  end,
  desc = "Manually load specific LSP"
})

-- Debug commands
vim.api.nvim_create_user_command("LspStatus", function()
  print("LSPSaga available: " .. tostring(has_lspsaga))
  local clients = vim.lsp.get_active_clients()
  print("Active LSP clients:")
  for _, client in ipairs(clients) do
    print("  - " .. client.name .. " (id: " .. client.id .. ")")
  end
  
  -- Check for potential conflicts
  local bufnr = vim.api.nvim_get_current_buf()
  local buffer_clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  if #buffer_clients > 1 then
    print("⚠️  Multiple LSP clients attached to current buffer:")
    for _, client in ipairs(buffer_clients) do
      print("    - " .. client.name)
    end
    print("This might cause double floating windows. Consider using :LspRestart")
  end
end, { desc = "Show LSP status and active clients" })

-- Add command to restart LSPSaga if issues persist
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
