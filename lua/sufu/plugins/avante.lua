require("avante").setup({
  -- Provider configuration - Ollama is now a first-class provider
  provider = "ollama",
  cursor_applying_provider = 'ollama',
  -- Ollama configuration
  ollama = {
    endpoint = "http://127.0.0.1:11434/",
    model = "qwen2.5:7b",
    timeout = 30000, -- Timeout in milliseconds
    temperature = 0,
    max_tokens = 4096,
  },
  -- General Avante configuration
  behaviour = {
    auto_suggestions = true, -- Experimental stage
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = true,
    support_paste_from_clipboard = true,
  },

  mappings = {
    --- @class AvanteConflictMappings
    -- diff = {
    --   ours = "co",
    --   theirs = "ct",
    --   all_theirs = "ca",
    --   both = "cb",
    --   cursor = "cc",
    --   next = "]x",
    --   prev = "[x",
    -- },
    -- suggestion = {
    --   accept = "<M-l>",
    --   next = "<M-]>",
    --   prev = "<M-[>",
    --   dismiss = "<C-]>",
    -- },
    -- jump = {
    --   next = "]]",
    --   prev = "[[",
    -- },
    -- submit = {
    --   normal = "<CR>",
    --   insert = "<C-s>",
    -- },
    -- sidebar = {
    --   apply_all = "A",
    --   apply_cursor = "a",
    --   switch_windows = "<Tab>",
    --   reverse_switch_windows = "<S-Tab>",
    -- },
  },

  hints = { enabled = true },
  windows = {
    ---@type "right" | "left" | "top" | "bottom"
    position = "right",
    wrap = true,
    width = 30,
    sidebar_header = {
      align = "center",
      rounded = true,
    },
  },
  highlights = {
    ---@type AvanteConflictHighlights
    diff = {
      current = "DiffText",
      incoming = "DiffAdd",
    },
  },
  --- @class AvanteConflictUserConfig
  diff = {
    autojump = true,
    ---@type string | fun(): string
    list_opener = "copen",
  },
 system_prompt = function()
    local hub = require("mcphub").get_hub_instance()
    local prompt = hub and hub:get_active_servers_prompt() or ""
    return prompt
  end,
  custom_tools = function()
    local tools = {
      require("mcphub.extensions.avante").mcp_tool(),
    }
    return tools
  end,
  debug= false,
})
