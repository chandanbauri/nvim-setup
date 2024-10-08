-- import nvim-autopairs safely
local autopairs_setup, autopairs = pcall(require, "nvim-autopairs")
if not autopairs_setup then
	return
end

-- configure autopairs
autopairs.setup({
	check_ts = true, -- enable treesitter globally for all languages
	ts_config = {
		-- Leave empty to apply globally, or add specific exclusions if needed
		-- Example: exclude_filetype = { "python", "javascript" }
	},
	disable_filetype = { "TelescopePrompt", "spectre_panel" }, -- disable in Telescope and Spectre
	fast_wrap = {}, -- enable fast wrapping (optional)
})
-- import nvim-autopairs completion functionality safely
local cmp_autopairs_setup, cmp_autopairs = pcall(require, "nvim-autopairs.completion.cmp")
if not cmp_autopairs_setup then
	return
end

-- import nvim-cmp plugin safely (completions plugin)
local cmp_setup, cmp = pcall(require, "cmp")
if not cmp_setup then
	return
end

-- make autopairs and completion work together
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
