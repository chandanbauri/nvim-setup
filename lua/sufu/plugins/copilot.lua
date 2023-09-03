vim.g.copilot_filetypes = { xml = false, markdown = false }

-- vim.cmd([[imap <silent><script><expr><C-p> copilot#Accept("\<CR>")]])
--
-- vim.g.copilot_no_tab_map = true

vim.cmd([[highlight CopilotSuggestion guifg=#FF00FF ctermfg=8]])
