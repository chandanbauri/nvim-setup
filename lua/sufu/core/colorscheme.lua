-- set colorscheme to nightfly with protected call
-- in case it isn't installed
-- local status, _ = pcall(vim.cmd, "colorscheme nightfly")
-- if not status then
--  print("Colorscheme not found!") -- print error if colorscheme not installed
--  return
-- end
local fm = require("fluoromachine")

function overrides(c)
	return {
		TelescopeResultsBorder = { fg = c.alt_bg, bg = c.alt_bg },
		TelescopeResultsNormal = { bg = c.alt_bg },
		TelescopePreviewNormal = { bg = c.bg },
		TelescopePromptBorder = { fg = c.alt_bg, bg = c.alt_bg },
		TelescopeTitle = { fg = c.fg, bg = c.comment },
		TelescopePromptPrefix = { fg = c.purple },
		["@type"] = { italic = true, bold = false },
		["@function"] = { italic = false, bold = false },
		["@comment"] = { italic = true, fg = c.cyan },
		["@keyword"] = { italic = false, fg = c.pink },
		["@constant"] = { italic = false, bold = false, fg = c.red },
		["@variable"] = { italic = true, fg = c.orange },
		["@field"] = { italic = true, fg = c.orange },
		["@parameter"] = { italic = true },
	}
end

function colors(_, d)
	return {
		bg = "#190920",
		alt_bg = d("#190920", 20),
		cyan = "#49eaff",
		red = "#ff1e34",
		yellow = "#ffe756",
		orange = "#f38e21",
		pink = "#ffadff",
		purple = "#9544f7",
	}
end

fm.setup({
	glow = false,
	theme = "fluoromachine",
	transparent = "full",
	overrides = overrides,
	colors = colors,
})

vim.o.termguicolors = true
local status, _ = pcall(vim.cmd, "colorscheme fluoromachine")
if not status then
	print("cat colorscheme not found")
	return
end
