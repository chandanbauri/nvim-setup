local ai_setup, ai = pcall(require, "ollama")
if not ai_setup then
  return
end

-- ai.setup({
--   popup_layout = {
--     relative = "editor",
--     position = "50%",
--     size = {
--       width = "80%",
--       height = "80%",
--     },
--   },
--   api_host = "http://localhost:11434",
--   api_key_cmd = nil,
--   model = "codellama"
-- })

ai.setup({
  model = "codellama",
  url = "http://localhost:11434",
})
