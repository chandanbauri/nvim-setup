local setup, flutterTools = pcall(require, "flutter-tools")
if not setup then
	return
end

flutterTools.setup({})
