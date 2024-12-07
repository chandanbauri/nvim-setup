vim.cmd([[set rtp+=~/.fzf]])
-- vim.g.fzf_layout = { down = "40%" }
vim.g.fzf_command_prefix = "FZF"
vim.g.fzf_layout = {
	window = {
		width = 0.6,
		height = 0.6,
		relative = true,
		yoffset = 1.0,
	},
	down = "40%",
}
