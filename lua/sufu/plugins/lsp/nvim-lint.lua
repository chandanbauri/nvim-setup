local setup, nvim_lint = pcall(require, "lint")


require("lint").linters_by_ft = {
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  -- lua = { "luacheck" },
  python = { "flake8" },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})
