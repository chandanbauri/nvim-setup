local setup, bigfile = pcall(require, "bigfile")
if not setup then
	return
end

bigfile.setup({
	filesize = 1,
	pattern = { "*" },
})
