vim.cmd([[set rtp+=~/.fzf]])
vim.g.fzf_command_prefix = "FZF"
vim.g.fzf_layout = {
	window = {
		width = 1,
		height = 1,
		relative = "editor",
		row = 0.1,
		col = 0.1,
		yoffset = 1.0,
		border = "rounded",
	},
}
