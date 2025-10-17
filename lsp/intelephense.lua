return {
  cmd = { 'intelephense', '--stdio' },
  filetypes = { 'php' },
  root_markers = { 'composer.json', '.git' },
  settings = {
    intelephense = {
      format = {
        enable = true,
      },
      files = {
        maxSize = 5000000,
      },
    },
  },
}
