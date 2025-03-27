-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

vim.api.nvim_create_user_command("CloseBuff", function()
	-- local current_win = vim.api.nvim_get_current_win() -- Get current window ID
	--
	local bufnr = vim.api.nvim_get_current_buf()
	local buftype = vim.bo[bufnr].buftype

	local last_win = vim.fn.winnr("$") -- Get the last window number

	if buftype == "" then
		print("This is a normal buf can not close!")
	else
		vim.cmd("close")
	end
end, { nargs = "?" })

local function if_file_exists(filename)
	local stat = vim.loop.fs_stat(filename)
	return stat ~= nil
end

local function if_node_project()
	local exists = if_file_exists("package.json")
	if exists then
		vim.api.nvim_create_user_command("NPMRUNDEV", function()
			local buf = vim.api.nvim_create_buf(false, true)

			vim.api.nvim_command("tabnew")
			vim.api.nvim_command("buffer " .. buf)

			vim.fn.termopen("npm run dev", {
				on_exit = function()
					print("npm run dev exited.")
				end,
			})
		end, { nargs = "?" })
	end
end

if_node_project()

---------------------
-- General Keymaps
---------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>")

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>") -- increment
keymap.set("n", "<leader>-", "<C-x>") -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab
keymap.set("n", "<leader>tt", ":Lspsaga term_toggle<CR>")

keymap.set("t", "<leader>tt", ":Lspsaga term_toggle<CR>")
keymap.set("t", "<Esc>", "<C-\\><C-N>", { noremap = true, silent = true })
keymap.set("n", "<Esc>", ":CloseBuff<CR>", { noremap = true, silent = true })

----------------------
-- Plugin Keybinds
----------------------

-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle split window maximization

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>") -- toggle file explorer

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", ":FZFRG<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- telescope git commands (not on youtube nvim video)
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]
keymap.set("n", "<leader>gls", "<cmd>Telescope git_stash<cr>") -- list current changes per file with diff preview ["gs" for git status]

keymap.set("n", "<leader>sps", "<cmd>Telescope spell_suggest<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- restart lsp server (not on youtube nvim video)
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary

-- toggle html live server toggle
keymap.set("n", "<leader>tls", ":LiveServerToggle<CR>")

keymap.set("n", "<leader>plt", "<cmd>Telescope planets<cr>")

keymap.set("n", "<leader>du", ":DBUI<CR>")
keymap.set("n", "<leader>dut", ":DBUIToggle<CR>")
