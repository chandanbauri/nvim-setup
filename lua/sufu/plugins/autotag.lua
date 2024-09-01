local setup, autotag = pcall(require, "nvim-ts-autotag")
if not setup then
	return
end

autotag.setup({
	filetypes = {
		"html",
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
		"svelte",
		"vue",
		"xml",
		"php",
		"markdown",
		"glimmer",
		"handlebars",
		"hbs",
		"astro",
	},
	skip_tags = {
		"area",
		"base",
		"br",
		"col",
		"embed",
		"hr",
		"img",
		"input",
		"keygen",
		"link",
		"meta",
		"param",
		"source",
		"track",
		"wbr",
	},
})
