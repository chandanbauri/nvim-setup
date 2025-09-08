-- import nvim-cmp plugin safely
local cmp_status, cmp = pcall(require, "cmp")
if not cmp_status then
	return
end

-- import luasnip plugin safely
local luasnip_status, luasnip = pcall(require, "luasnip")
if not luasnip_status then
	return
end

-- import lspkind plugin safely
local lspkind_status, lspkind = pcall(require, "lspkind")
if not lspkind_status then
	return
end

-- load vs-code like snippets from plugins (e.g. friendly-snippets)
require("luasnip/loaders/from_vscode").lazy_load()

vim.opt.completeopt = "menu,menuone,noselect"

-- Enhanced cmp setup with better source prioritization
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		-- Navigation with Ctrl+j/k (consistent across all contexts)
		["<C-k>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "c" }),
		["<C-j>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "c" }),
		
		-- Scroll documentation with Ctrl+u/d (more intuitive)
		["<C-u>"] = cmp.mapping.scroll_docs(-4),
		["<C-d>"] = cmp.mapping.scroll_docs(4),
		
		-- Alternative documentation scrolling (keeping original)
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		
		-- Completion control
		["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
		["<C-e>"] = cmp.mapping.abort(), -- close completion window
		["<CR>"] = cmp.mapping.confirm({ 
			select = true,
			behavior = cmp.ConfirmBehavior.Insert,
		}),
		
		-- Tab completion for snippets and navigation
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
		
		-- Arrow keys as backup (for muscle memory)
		["<Up>"] = cmp.mapping.select_prev_item(),
		["<Down>"] = cmp.mapping.select_next_item(),
	}),
	-- Global sources for autocompletion (prioritized by order)
	sources = cmp.config.sources({
		{ 
			name = "nvim_lsp", 
			priority = 1000,
			-- Show more LSP completions
			max_item_count = 20,
		},
		{ 
			name = "luasnip", 
			priority = 750,
			max_item_count = 5,
		},
		{ 
			name = "vim-dadbod-completion",
			priority = 700,
		},
		{ 
			name = "path", 
			priority = 500,
			max_item_count = 10,
		},
	}, {
		-- Secondary sources (lower priority)
		{ 
			name = "buffer", 
			priority = 250,
			max_item_count = 5,
			-- Only show buffer completions for longer words to reduce noise
			keyword_length = 3,
		},
		{ 
			name = "ollama", 
			priority = 200,
			keyword_length = 2,
			max_item_count = 3,
		},
	}),
	-- Enhanced formatting with better icons and source labels
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text",
			maxwidth = 50,
			ellipsis_char = "...",
			-- Show source in completion menu
			menu = {
				nvim_lsp = "[LSP]",
				luasnip = "[Snip]",
				buffer = "[Buf]",
				path = "[Path]",
				["vim-dadbod-completion"] = "[DB]",
				ollama = "[AI]",
			},
			-- Custom formatting for different completion types
			before = function(entry, vim_item)
				-- Highlight auto-import completions
				if entry.source.name == "nvim_lsp" then
					if entry.completion_item.detail and 
					   entry.completion_item.detail:match("Auto import") then
						vim_item.kind = vim_item.kind .. " (import)"
					end
				end
				return vim_item
			end,
		}),
	},
	-- Enhanced completion behavior
	completion = {
		completeopt = "menu,menuone,noselect",
	},
	-- Experimental features for better performance
	performance = {
		debounce = 150,
		throttle = 50,
		fetching_timeout = 200,
	},
	-- Enhanced sorting to prioritize LSP completions
	sorting = {
		priority_weight = 2,
		comparators = {
			-- Prioritize exact matches
			cmp.config.compare.exact,
			-- Prioritize LSP completions
			cmp.config.compare.score,
			-- Then by source priority
			cmp.config.compare.recently_used,
			cmp.config.compare.locality,
			-- Default comparators
			cmp.config.compare.offset,
			cmp.config.compare.order,
		},
	},
})

-- ===============================
-- DART/FLUTTER SPECIFIC CONFIGURATION
-- ===============================
-- This ensures Dart files prioritize LSP completions with auto-imports
cmp.setup.filetype("dart", {
	sources = cmp.config.sources({
		{
			name = "nvim_lsp",
			priority = 1000,
			-- Show more LSP items for Dart
			max_item_count = 25,
			-- Filter to prioritize auto-import completions
			entry_filter = function(entry, ctx)
				-- Always include LSP completions
				return true
			end,
		},
		{
			name = "luasnip",
			priority = 800,
			max_item_count = 5,
		},
		{
			name = "path",
			priority = 600,
			max_item_count = 5,
		},
	}, {
		-- Lower priority sources for Dart files
		{
			name = "buffer",
			priority = 200,
			max_item_count = 3,
			-- Only show buffer completions for longer words in Dart files
			keyword_length = 4,
		},
	}),
	-- Dart-specific formatting
	formatting = {
		format = lspkind.cmp_format({
			mode = "symbol_text",
			maxwidth = 60, -- Slightly wider for Dart class names
			ellipsis_char = "...",
			menu = {
				nvim_lsp = "[Dart LSP]",
				luasnip = "[Snippet]",
				buffer = "[Buffer]",
				path = "[Path]",
			},
			before = function(entry, vim_item)
				-- Special handling for Dart completions
				if entry.source.name == "nvim_lsp" then
					local completion_item = entry.completion_item
					
					-- Mark auto-import items clearly
					if completion_item.additionalTextEdits or 
					   (completion_item.detail and completion_item.detail:match("import")) then
						vim_item.menu = "[Auto-import]"
						-- Boost priority for auto-import items
						vim_item.priority = 1000
					end
					
					-- Show library information for external packages
					if completion_item.detail then
						local detail = completion_item.detail
						if detail:match("dart:") or detail:match("package:") then
							vim_item.menu = "[" .. detail:match("([^/]+)") .. "]"
						end
					end
				end
				return vim_item
			end,
		}),
	},
})

-- ===============================
-- LSP NAVIGATION ENHANCEMENT
-- ===============================

-- Enhanced LSP mappings for consistent Ctrl+j/k navigation
local function setup_lsp_navigation_mappings()
	-- Global mappings for LSP floating windows
	local keymap = vim.keymap
	
	-- Override default LSP hover behavior to use Ctrl+j/k for navigation
	local original_hover = vim.lsp.buf.hover
	vim.lsp.buf.hover = function()
		local _, winid = original_hover()
		if winid then
			-- Set up navigation in hover window
			vim.api.nvim_buf_set_keymap(0, 'n', '<C-j>', '<C-e>', { noremap = true, silent = true })
			vim.api.nvim_buf_set_keymap(0, 'n', '<C-k>', '<C-y>', { noremap = true, silent = true })
		end
	end
	
	-- Enhanced signature help with navigation
	local original_signature_help = vim.lsp.buf.signature_help
	vim.lsp.buf.signature_help = function()
		local _, winid = original_signature_help()
		if winid then
			-- Set up navigation in signature help window
			vim.api.nvim_buf_set_keymap(0, 'n', '<C-j>', '<C-e>', { noremap = true, silent = true })
			vim.api.nvim_buf_set_keymap(0, 'n', '<C-k>', '<C-y>', { noremap = true, silent = true })
		end
	end
end

-- Set up LSP navigation enhancement
setup_lsp_navigation_mappings()

-- ===============================
-- FLOATING WINDOW NAVIGATION
-- ===============================

-- Global function to enhance any floating window with Ctrl+j/k navigation
local function enhance_floating_window(winid)
	if winid and vim.api.nvim_win_is_valid(winid) then
		local bufnr = vim.api.nvim_win_get_buf(winid)
		
		-- Set up keymaps for the floating window
		local opts = { buffer = bufnr, noremap = true, silent = true }
		
		-- Navigation mappings
		vim.keymap.set('n', '<C-j>', '<C-e>', opts) -- Scroll down
		vim.keymap.set('n', '<C-k>', '<C-y>', opts) -- Scroll up
		vim.keymap.set('n', '<C-d>', '<C-d>', opts) -- Page down
		vim.keymap.set('n', '<C-u>', '<C-u>', opts) -- Page up
		vim.keymap.set('n', 'q', '<C-w>c', opts)    -- Quick close
		vim.keymap.set('n', '<Esc>', '<C-w>c', opts) -- Quick close
		
		-- Focus the floating window for immediate navigation
		vim.api.nvim_set_current_win(winid)
	end
end

-- Auto-enhance floating windows with navigation
vim.api.nvim_create_autocmd("WinNew", {
	callback = function()
		vim.defer_fn(function()
			local winid = vim.api.nvim_get_current_win()
			local config = vim.api.nvim_win_get_config(winid)
			
			-- Check if it's a floating window
			if config.relative ~= "" then
				enhance_floating_window(winid)
			end
		end, 10)
	end,
})

-- ===============================
-- DART-SPECIFIC LSP ENHANCEMENTS
-- ===============================

-- Enhanced Dart LSP navigation setup
vim.api.nvim_create_autocmd("LspAttach", {
	pattern = "*.dart",
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client.name == "dartls" then
			local opts = { buffer = ev.buf, noremap = true, silent = true }
			
			-- Enhanced hover with navigation
			vim.keymap.set('n', 'K', function()
				vim.lsp.buf.hover()
				-- Focus floating window for navigation
				vim.defer_fn(function()
					local windows = vim.api.nvim_list_wins()
					for _, winid in ipairs(windows) do
						local config = vim.api.nvim_win_get_config(winid)
						if config.relative ~= "" then
							enhance_floating_window(winid)
							break
						end
					end
				end, 50)
			end, opts)
			
			-- Enhanced signature help with navigation
			vim.keymap.set('n', '<leader>k', function()
				vim.lsp.buf.signature_help()
				-- Focus floating window for navigation
				vim.defer_fn(function()
					local windows = vim.api.nvim_list_wins()
					for _, winid in ipairs(windows) do
						local config = vim.api.nvim_win_get_config(winid)
						if config.relative ~= "" then
							enhance_floating_window(winid)
							break
						end
					end
				end, 50)
			end, opts)
		end
	end,
})

-- ===============================
-- INTEGRATION WITH OTHER PLUGINS
-- ===============================

-- nvim-autopairs integration
local autopairs_setup, autopairs = pcall(require, "nvim-autopairs")
if autopairs_setup then
	local cmp_autopairs_setup, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
	if cmp_autopairs_setup then
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end
end

-- ===============================
-- ADDITIONAL DART/FLUTTER HELPERS
-- ===============================

-- Function to refresh LSP completions (useful when imports are not working)
_G.refresh_dart_completions = function()
	-- Clear LSP caches
	for _, client in pairs(vim.lsp.get_active_clients()) do
		if client.name == "dartls" then
			client.stop()
			vim.defer_fn(function()
				vim.cmd("LspStart dartls")
			end, 1000)
		end
	end
	vim.notify("Dart LSP refreshed", vim.log.levels.INFO)
end

-- Command to refresh Dart completions
vim.api.nvim_create_user_command("DartRefreshCompletions", function()
	_G.refresh_dart_completions()
end, { desc = "Refresh Dart LSP completions" })

-- Auto-command to ensure proper LSP setup for Dart files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dart",
	callback = function()
		-- Ensure LSP is attached
		vim.defer_fn(function()
			local clients = vim.lsp.get_active_clients({ bufnr = 0 })
			local dartls_attached = false
			for _, client in pairs(clients) do
				if client.name == "dartls" then
					dartls_attached = true
					break
				end
			end
			
			if not dartls_attached then
				vim.notify("Dart LSP not attached. Try :LspStart dartls", vim.log.levels.WARN)
			end
		end, 500)
	end,
})

-- ===============================
-- COMPLETION MENU CUSTOMIZATION
-- ===============================

-- Custom highlight groups for better visual distinction
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		-- Highlight auto-import completions differently
		vim.api.nvim_set_hl(0, "CmpItemKindAutoImport", { 
			fg = "#A6E3A1", -- Green color for auto-imports
			bg = "NONE",
			bold = true 
		})
		
		-- Highlight LSP completions
		vim.api.nvim_set_hl(0, "CmpItemKindLSP", {
			fg = "#89B4FA", -- Blue color for LSP items
			bg = "NONE"
		})
	end,
})

-- vim.notify("Enhanced nvim-cmp configuration loaded with Dart auto-import priority! 🚀", vim.log.levels.INFO)

-- ===============================
-- TROUBLESHOOTING & TIPS
-- ===============================

-- Function to check if Ctrl+j/k mappings are working
_G.check_completion_mappings = function()
	local mappings = vim.api.nvim_get_keymap('i')
	local found_cj = false
	local found_ck = false
	
	for _, mapping in ipairs(mappings) do
		if mapping.lhs == '<C-j>' then
			found_cj = true
			print("Ctrl+j mapping found: " .. (mapping.rhs or ""))
		elseif mapping.lhs == '<C-k>' then  
			found_ck = true
			print("Ctrl+k mapping found: " .. (mapping.rhs or ""))
		end
	end
	
	if found_cj and found_ck then
		-- vim.notify("✅ Ctrl+j/k mappings are properly configured!", vim.log.levels.INFO)
	else
		vim.notify("❌ Some Ctrl+j/k mappings are missing", vim.log.levels.WARN)
	end
end

-- Command to check mappings
vim.api.nvim_create_user_command("CheckCompletionMappings", function()
	_G.check_completion_mappings()
end, { desc = "Check if Ctrl+j/k completion mappings are working" })

-- ===============================
-- ADDITIONAL DART COMPLETION HELPERS
-- ===============================

-- Force show LSP completions with Ctrl+Space even when other sources are active
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dart",
	callback = function()
		-- Additional Dart-specific insert mode mappings
		local opts = { buffer = true, noremap = true, silent = true }
		
		-- Force LSP completion trigger
		vim.keymap.set('i', '<C-l>', function()
			cmp.complete({
				config = {
					sources = {
						{ name = 'nvim_lsp' }
					}
				}
			})
		end, opts)
		
		-- Quick snippet expansion
		vim.keymap.set('i', '<C-s>', function()
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			end
		end, opts)
	end,
})

-- ===============================
-- DEBUGGING HELPERS
-- ===============================

-- Debug function to show current completion sources
_G.debug_completion_sources = function()
	if cmp.visible() then
		local entries = cmp.get_entries()
		print("Current completion sources:")
		for i, entry in ipairs(entries) do
			if i <= 10 then -- Show first 10 entries
				print(string.format("%d. [%s] %s", i, entry.source.name, entry.completion_item.label))
			end
		end
	else
		print("No completion menu visible")
	end
end

-- Command to debug completion sources
vim.api.nvim_create_user_command("DebugCompletionSources", function()
	_G.debug_completion_sources()
end, { desc = "Debug current completion sources" })
