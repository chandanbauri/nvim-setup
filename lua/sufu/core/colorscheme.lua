-- set colorscheme to nightfly with protected call
-- in case it isn't installed
-- local status, _ = pcall(vim.cmd, "colorscheme nightfly")
-- if not status then
--  print("Colorscheme not found!") -- print error if colorscheme not installed
--  return
-- end

require("catppuccin").setup({
	flavour = "macchiato",
	transparent_background = true,
	dim_inactive = {
		enabled = false, -- dims the background color of inactive window
		shade = "dark",
		percentage = 0.15, -- percentage of the shade to apply to the inactive window
	},
	styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
		comments = { "italic" }, -- Change the style of comments
		conditionals = { "italic" },
		loops = { "italic" },
		functions = {
			"italic",
		},
		keywords = {},
		strings = {
			"italic",
		},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
		-- miscs = {}, -- Uncomment to turn off hard-coded styles
	},
	default_integrations = true,
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		treesitter = true,
		native_lsp = {
			enabled = true,
			virtual_text = {
				errors = { "italic" },
				hints = { "italic" },
				warnings = { "italic" },
				information = { "italic" },
			},
			underlines = {
				errors = { "underline" },
				hints = { "underline" },
				warnings = { "underline" },
				information = { "underline" },
			},
			inlay_hints = {
				background = true,
			},
		},
		telescope = {
			enabled = true,
			-- style = "nvchad"
		},
		-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
	},
})
vim.o.termguicolors = true
local status, _ = pcall(vim.cmd, "colorscheme catppuccin")
if not status then
	print("cat colorscheme not found")
	return
end
