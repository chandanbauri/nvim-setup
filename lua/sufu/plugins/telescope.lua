-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
	return
end
local file_ignore_patterns = {
	"%.png",
	"%.svg",
	"%.min%.js",
	"%.min%.ts",
	"%.min%.css",
	"%.ttf",
	"node_modules/",
	"public/",
	"%.git/",
	"%.github/",
}
telescope.load_extension("fzf")
-- configure telescope
telescope.setup({
	-- configure custom mappings
	defaults = {
		mappings = {
			i = {
				["<C-k>"] = actions.move_selection_previous, -- move to prev result
				["<C-j>"] = actions.move_selection_next, -- move to next result
				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
			},
		},
		file_ignore_patterns = file_ignore_patterns,
		preview = false,
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
	},
	pickers = {
		live_grep = {
			file_ignore_patterns = file_ignore_patterns,
			hidden = false,
			grep_open_files = false,
			preview = false,
		},
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})
