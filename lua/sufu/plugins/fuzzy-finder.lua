vim.cmd([[set rtp+=~/.fzf]])

vim.g.fzf_command_prefix = "FZF"

vim.g.fzf_vim = {
	listproc = function(list)
		vim.fn.setqflist(list)
		vim.cmd("copen")
		vim.cmd("wincmd p") -- Return to the previous window
	end,
}

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

vim.g.fzf_action = {
	["ctrl-c"] = "close",
	["ctrl-q"] = "quickfix",
	["ctrl-t"] = "tabedit",
}

-- vim.cmd([[
--   command! FZFRG call fzf#vim#grep(
--     \ 'rg --column --line-number --no-heading --color=always --smart-case ".*"',
--     \ 1,
--     \ fzf#vim#with_preview({'options': '--bind esc:abort,ctrl-c:abort'}),
--     \ 0)
-- ]])
--
vim.cmd([[
    command! FZFRG call fzf#vim#grep(
      \ 'rg --column --line-number --no-heading --color=always --smart-case ".*"',
      \ 1,
      \ fzf#vim#with_preview({'options': '--bind esc:abort,ctrl-c:abort'}),
      \ 0)
]])
