local setup, bigfile = pcall(require, "faster")
if not setup then
	return
end

-- bigfile.setup({
-- 	filesize = 1,
-- 	pattern = { "*" },
-- })
--
bigfile.setup()
