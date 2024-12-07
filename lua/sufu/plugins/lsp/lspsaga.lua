-- import lspsaga safely
local saga_status, saga = pcall(require, "lspsaga")
if not saga_status then
	return
end

saga.setup({
	code_action = {
		enable = true,
		show_server_name = true,
		extend_gitsigns = true,
		keys = {
			quit = { "ESC", "q", "<leader>sx" },
		},
	},
	scroll_preview = { scroll_down = "<C-f>", scroll_up = "<C-b>" },
	definition = {
		width = 0.5,
		height = 0.6,
		keys = {
			edit = "<CR>",
		},
	},
	ui = {
		-- colors = require("catppuccin.groups.integrations.lsp_saga").custom_colors(),
		-- kind = require("catppuccin.groups.integrations.lsp_saga").custom_kind(),
	},
	finder = {
		max_height = 0.6,
		keys = {
			vsplit = "v",
		},
	},
})
