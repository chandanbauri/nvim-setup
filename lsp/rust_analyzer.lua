return {
  cmd = { 'rustup', 'run', 'stable', 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json' },
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
        loadOutDirsFromCheck = true,
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
        attributes = {
          enable = true,
        },
      },
      diagnostics = {
        enable = true,
        enableExperimental = true,
      },
      check = {
        command = "clippy",
        extraArgs = { "--no-deps" },
        allFeatures = true,
        allTargets = true,
      },
      completion = {
        autoimport = {
          enable = true,
        },
        callable = {
          snippets = "fill_arguments",
        },
      },
      imports = {
        merge = {
          blob = true,
        },
        prefix = "crate",
        group = {
          enable = true,
        },
      },
      inlayHints = {
        enable = true,
        showParameterNames = false,
        parameterHintsPrefix = "<- ",
        otherHintsPrefix = "=> ",
        maxLength = 50,
        bindingModeHints = {
          enable = false,
        },
        chainingHints = {
          enable = true,
        },
        closingBraceHints = {
          enable = true,
          minLines = 25,
        },
        closureReturnTypeHints = {
          enable = "never",
        },
        lifetimeElisionHints = {
          enable = "never",
          useParameterNames = false,
        },
        typeHints = {
          enable = true,
          hideClosureInitialization = false,
          hideNamedConstructor = false,
        },
      },
      lens = {
        enable = true,
        debug = {
          enable = true,
        },
        implementations = {
          enable = true,
        },
        run = {
          enable = true,
        },
      },
    },
  },
}
