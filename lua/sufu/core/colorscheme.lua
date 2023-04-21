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
})

local status, _ = pcall(vim.cmd, "colorscheme catppuccin")
if not status then
	print("cat colorscheme not found")
	return
end
