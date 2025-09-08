-- Enhanced Flutter development setup for Neovim
-- Only loads when in a Flutter project
-- Requires: flutter-tools.nvim, nvim-dap (optional), nvim-cmp, telescope.nvim

-- Function to detect if current directory is a Flutter project
local function is_flutter_project()
	local pubspec_path = vim.fn.findfile("pubspec.yaml", ".;")
	if pubspec_path == "" then
		return false
	end
	
	-- Check if pubspec.yaml contains Flutter dependencies
	local pubspec_content = vim.fn.readfile(pubspec_path)
	for _, line in ipairs(pubspec_content) do
		if line:match("flutter:") then
			return true
		end
	end
	return false
end

-- Early return if not a Flutter project
if not is_flutter_project() then
	return
end

local function safe_require(module)
	local status, result = pcall(require, module)
	if not status then
		vim.notify("Failed to load " .. module, vim.log.levels.ERROR)
		return nil
	end
	return result
end

-- Required modules
local dap = safe_require("dap")
local flutter_tools = safe_require("flutter-tools")
local cmp_nvim_lsp = safe_require("cmp_nvim_lsp")
local telescope = safe_require("telescope")

-- Early return if essential modules are missing
if not flutter_tools or not cmp_nvim_lsp then
	vim.notify("Essential Flutter tools not available", vim.log.levels.ERROR)
	return
end

-- DAP configuration for Flutter debugging (optional)
if dap then
	dap.set_log_level("INFO")
	
	-- Configure DAP adapters for Dart/Flutter
	dap.adapters.dart = {
		type = "executable",
		command = "dart",
		args = { "debug_adapter" },
		options = {
			detached = false,
		},
	}
	
	-- DAP configurations will be automatically registered by flutter-tools
	-- You can also manually configure them if needed
	dap.configurations.dart = {
		{
			type = "dart",
			request = "launch",
			name = "Launch Flutter Debug",
			dartSdkPath = vim.fn.expand("~/flutter/bin/cache/dart-sdk/"),
			flutterSdkPath = vim.fn.expand("~/flutter"),
			program = "${workspaceFolder}/lib/main.dart",
			cwd = "${workspaceFolder}",
			args = { "--debug" },
		},
		{
			type = "dart",
			request = "launch",
			name = "Launch Flutter Profile",
			dartSdkPath = vim.fn.expand("~/flutter/bin/cache/dart-sdk/"),
			flutterSdkPath = vim.fn.expand("~/flutter"),
			program = "${workspaceFolder}/lib/main.dart",
			cwd = "${workspaceFolder}",
			args = { "--profile" },
		},
		{
			type = "dart",
			request = "attach",
			name = "Attach to Flutter",
			dartSdkPath = vim.fn.expand("~/flutter/bin/cache/dart-sdk/"),
			flutterSdkPath = vim.fn.expand("~/flutter"),
			cwd = "${workspaceFolder}",
		}
	}
end

-- Enhanced capabilities for LSP
local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { "documentation", "detail", "additionalTextEdits" }
}

-- LSP keybinding setup
local keymap = vim.keymap
local augroup = vim.api.nvim_create_augroup("FlutterLsp", { clear = true })

-- Enhanced on_attach function with native LSP functionality
local function on_attach(client, bufnr)
	-- Enable formatting capabilities
	if client.server_capabilities.documentFormattingProvider then
		client.server_capabilities.documentFormattingProvider = true
	end
	if client.server_capabilities.documentRangeFormattingProvider then
		client.server_capabilities.documentRangeFormattingProvider = true
	end
	
	-- Clear previous autocmds
	vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
	
	-- Auto-format on save (optional - uncomment if desired)
	-- vim.api.nvim_create_autocmd("BufWritePre", {
	-- 	group = augroup,
	-- 	buffer = bufnr,
	-- 	callback = function()
	-- 		vim.lsp.buf.format({ async = false })
	-- 	end,
	-- })

	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- Custom Flutter commands (non-conflicting with flutter-tools)
	local custom_commands = {
		{ "FlutterCleanAndGet", "flutter clean && flutter pub get", "Clean and get dependencies" },
		{ "FlutterPubUpgrade", "flutter pub upgrade", "Upgrade Flutter dependencies" },
		{ "FlutterDoctor", "flutter doctor", "Run Flutter doctor" },
		{ "FlutterBuildApk", "flutter build apk", "Build Flutter APK" },
		{ "FlutterBuildIos", "flutter build ios", "Build Flutter iOS" },
		{ "FlutterTest", "flutter test", "Run Flutter tests" },
		{ "FlutterAnalyze", "flutter analyze", "Analyze Flutter code" },
		{ "FlutterPubGet", "flutter pub get", "Get Flutter dependencies" },
	}

	for _, cmd in ipairs(custom_commands) do
		vim.api.nvim_create_user_command(cmd[1], function()
			vim.cmd("!" .. cmd[2])
		end, { nargs = "*", desc = cmd[3] })
	end

	-- ===============================
	-- NATIVE LSP KEYBINDINGS (No LSP Saga)
	-- ===============================
	
	-- Navigation
	keymap.set("n", "gd", vim.lsp.buf.definition) -- go to definition
	keymap.set("n", "gD", vim.lsp.buf.declaration) -- go to declaration
	keymap.set("n", "gi", vim.lsp.buf.implementation) -- go to implementation
	keymap.set("n", "gr", vim.lsp.buf.references) -- show references
	keymap.set("n", "gt", vim.lsp.buf.type_definition) -- go to type definition
	
	-- Documentation and hover
	keymap.set("n", "K", vim.lsp.buf.hover) -- hover documentation
	keymap.set("n", "<leader>k", vim.lsp.buf.signature_help) -- signature help
	
	-- Code actions and refactoring
	keymap.set("n", "<leader>ca", vim.lsp.buf.code_action) -- code actions
	keymap.set("v", "<leader>ca", vim.lsp.buf.code_action) -- code actions in visual mode
	keymap.set("n", "<leader>rn", vim.lsp.buf.rename) -- rename symbol
	
	-- Formatting
	keymap.set("n", "<leader>cf", function()
		vim.lsp.buf.format({ async = true })
	end, opts) -- format file
	keymap.set("v", "<leader>cf", function()
		vim.lsp.buf.format({ async = true })
	end, opts) -- format selection
	
	-- Diagnostics (native)
	keymap.set("n", "<leader>dl", vim.diagnostic.open_float, opts) -- line diagnostics
	keymap.set("n", "<leader>dq", vim.diagnostic.setloclist, opts) -- diagnostics to location list
	keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- previous diagnostic
	keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- next diagnostic
	keymap.set("n", "<leader>da", function()
		vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
	end, opts) -- cursor diagnostics
	
	-- Workspace symbols and document symbols
	keymap.set("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts) -- workspace symbols
	keymap.set("n", "<leader>ds", vim.lsp.buf.document_symbol, opts) -- document symbols
	
	-- ===============================
	-- FLUTTER-SPECIFIC KEYBINDINGS
	-- ===============================
	
	-- Flutter app management
	keymap.set("n", "<leader>fr", "<cmd>FlutterRun<CR>", opts) -- run Flutter app
	keymap.set("n", "<leader>fh", "<cmd>FlutterReload<CR>", opts) -- hot reload
	keymap.set("n", "<leader>fH", "<cmd>FlutterRestart<CR>", opts) -- hot restart
	keymap.set("n", "<leader>fq", "<cmd>FlutterQuit<CR>", opts) -- quit Flutter app
	keymap.set("n", "<leader>fD", "<cmd>FlutterDetach<CR>", opts) -- detach from device
	
	-- Device and emulator management
	keymap.set("n", "<leader>fd", "<cmd>FlutterDevices<CR>", opts) -- show devices
	keymap.set("n", "<leader>fe", "<cmd>FlutterEmulators<CR>", opts) -- show emulators
	
	-- Flutter development tools
	keymap.set("n", "<leader>ft", "<cmd>FlutterDevTools<CR>", opts) -- dev tools
	keymap.set("n", "<leader>fv", "<cmd>FlutterVisualDebug<CR>", opts) -- visual debug
	keymap.set("n", "<leader>fw", "<cmd>FlutterCopyProfilerUrl<CR>", opts) -- copy profiler URL
	
	-- Flutter outline
	keymap.set("n", "<leader>fo", "<cmd>FlutterOutlineToggle<CR>", opts) -- toggle outline
	keymap.set("n", "<leader>fO", "<cmd>FlutterOutlineOpen<CR>", opts) -- open outline
	
	-- Flutter LSP specific
	keymap.set("n", "<leader>fl", "<cmd>FlutterLspRestart<CR>", opts) -- restart LSP
	keymap.set("n", "<leader>fs", "<cmd>FlutterSuper<CR>", opts) -- go to super
	keymap.set("n", "<leader>fR", "<cmd>FlutterReanalyze<CR>", opts) -- reanalyze
	
	-- Flutter logs
	keymap.set("n", "<leader>fc", "<cmd>FlutterLogClear<CR>", opts) -- clear logs
	keymap.set("n", "<leader>fL", "<cmd>FlutterLogToggle<CR>", opts) -- toggle logs
	
	-- Custom commands keybindings
	keymap.set("n", "<leader>fcg", "<cmd>FlutterCleanAndGet<CR>", opts) -- clean and get
	keymap.set("n", "<leader>fu", "<cmd>FlutterPubUpgrade<CR>", opts) -- pub upgrade
	keymap.set("n", "<leader>fpg", "<cmd>FlutterPubGet<CR>", opts) -- pub get
	keymap.set("n", "<leader>fdd", "<cmd>FlutterDoctor<CR>", opts) -- flutter doctor
	keymap.set("n", "<leader>fba", "<cmd>FlutterBuildApk<CR>", opts) -- build APK
	keymap.set("n", "<leader>fbi", "<cmd>FlutterBuildIos<CR>", opts) -- build iOS
	keymap.set("n", "<leader>fT", "<cmd>FlutterTest<CR>", opts) -- run tests
	keymap.set("n", "<leader>fa", "<cmd>FlutterAnalyze<CR>", opts) -- analyze
	
	-- Telescope integration (if available)
	if telescope then
		keymap.set("n", "<leader>fsc", "<cmd>Telescope flutter commands<CR>", opts) -- Flutter commands
		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts) -- find files
		keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts) -- live grep
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts) -- buffers
		keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts) -- help tags
	end
	
	-- DAP debugging keybindings (if available)
	if dap then
		keymap.set("n", "<leader>db", dap.toggle_breakpoint, opts) -- toggle breakpoint
		keymap.set("n", "<leader>dB", function()
			dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
		end, opts) -- conditional breakpoint
		keymap.set("n", "<leader>dc", dap.continue, opts) -- continue
		keymap.set("n", "<leader>di", dap.step_into, opts) -- step into
		keymap.set("n", "<leader>do", dap.step_over, opts) -- step over
		keymap.set("n", "<leader>dO", dap.step_out, opts) -- step out
		keymap.set("n", "<leader>dr", dap.repl.open, opts) -- open REPL
		keymap.set("n", "<leader>dl", dap.run_last, opts) -- run last
		
		-- DAP UI keybindings (if nvim-dap-ui is available)
		local dapui = safe_require("dapui")
		if dapui then
			keymap.set("n", "<leader>du", dapui.toggle, opts) -- toggle DAP UI
			keymap.set("n", "<leader>de", dapui.eval, opts) -- evaluate expression
		end
	end
end

-- Flutter tools setup with enhanced configuration
flutter_tools.setup({
	ui = {
		border = "rounded",
		notification_style = "nvim", -- Use nvim notifications
	},
	decorations = {
		statusline = {
			app_version = true,
			device = true,
			project_config = true,
		},
	},
	debugger = {
		enabled = dap ~= nil, -- Enable debugger if DAP is available
		run_via_dap = dap ~= nil,
		exception_breakpoints = { "uncaught", "raised" },
		evaluate_to_string_in_debug_views = true,
		register_configurations = function(paths)
			if dap then
				-- Custom debug configurations
				dap.configurations.dart = {
					{
						type = "dart",
						request = "launch",
						name = "Launch Flutter (Debug)",
						dartSdkPath = paths.dart_sdk,
						flutterSdkPath = paths.flutter_sdk,
						program = "${workspaceFolder}/lib/main.dart",
						cwd = "${workspaceFolder}",
						args = { "--debug" },
					},
					{
						type = "dart",
						request = "launch",
						name = "Launch Flutter (Profile)",
						dartSdkPath = paths.dart_sdk,
						flutterSdkPath = paths.flutter_sdk,
						program = "${workspaceFolder}/lib/main.dart",
						cwd = "${workspaceFolder}",
						args = { "--profile" },
					},
					{
						type = "dart",
						request = "launch",
						name = "Launch Flutter (Release)",
						dartSdkPath = paths.dart_sdk,
						flutterSdkPath = paths.flutter_sdk,
						program = "${workspaceFolder}/lib/main.dart",
						cwd = "${workspaceFolder}",
						args = { "--release" },
					},
					{
						type = "dart",
						request = "attach",
						name = "Attach to Flutter",
						dartSdkPath = paths.dart_sdk,
						flutterSdkPath = paths.flutter_sdk,
						cwd = "${workspaceFolder}",
					}
				}
			end
		end,
	},
	widget_guides = {
		enabled = true,
		debug = false,
	},
	closing_tags = {
		highlight = "Comment",
		prefix = " // ",
		enabled = true,
		priority = 10,
	},
	dev_log = {
		enabled = true,
		notify_errors = true,
		open_cmd = "tabedit",
		focus_on_open = false,
		filter = nil, -- Optional callback to filter logs
	},
	dev_tools = {
		autostart = false,
		auto_open_browser = false,
	},
	outline = {
		open_cmd = "30vnew",
		auto_open = false,
	},
	lsp = {
		color = {
			enabled = true,
			background = true,
			background_color = { r = 19, g = 17, b = 24 },
			foreground = false,
			virtual_text = true,
			virtual_text_str = "■",
		},
		capabilities = capabilities,
		on_attach = on_attach,
		settings = {
			showTodos = true,
			completeFunctionCalls = true,
			renameFilesWithClasses = "prompt",
			enableSnippets = true,
			updateImportsOnRename = true,
			documentation = "full",
			enableSdkFormatter = true,
			lineLength = 120,
			insertArgumentPlaceholders = true,
			enableSuperParameter = true,
			analysisExcludedFolders = {
				vim.fn.expand("$HOME/flutter"),
				vim.fn.expand("$HOME/.pub-cache"),
			},
			includeDependenciesInWorkspaceSymbols = false,
			suggestFromUnimportedLibraries = true,
			closingLabels = true,
			maxCompletionItems = 50,
			previewDart = true,
		},
		init_options = {
			onlyAnalyzeProjectsWithOpenFiles = false,
			suggestFromUnimportedLibraries = true,
			closingLabels = true,
			outline = true,
			flutterOutline = true,
		},
	},
})

-- Setup Telescope extension for Flutter (if available)
if telescope then
	pcall(telescope.load_extension, "flutter")
end

-- Configure diagnostics appearance
vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		source = "always",
	},
	float = {
		source = "always",
		border = "rounded",
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

-- Set diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Additional Flutter-specific autocommands
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dart",
	callback = function()
		-- Set Flutter-specific options
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.expandtab = true
		vim.opt_local.colorcolumn = "120"
		
		-- Flutter-specific abbreviations
		local abbrevs = {
			stless = "StatelessWidget",
			stful = "StatefulWidget",
			CW = "Container",
			EL = "ElevatedButton",
			TB = "TextButton",
			GD = "GestureDetector",
			SB = "SizedBox",
			ROW = "Row",
			COL = "Column",
			ST = "Stack",
			SC = "Scaffold",
			AB = "AppBar",
			LSV = "ListView",
			GV = "GridView",
		}
		
		for abbrev, expansion in pairs(abbrevs) do
			vim.cmd(string.format("iabbrev <buffer> %s %s", abbrev, expansion))
		end
	end,
})

-- Create Flutter-specific highlights
vim.api.nvim_create_autocmd("ColorScheme", {
	callback = function()
		vim.api.nvim_set_hl(0, "FlutterWidgetGuides", { fg = "#3E4451", bg = "NONE" })
		vim.api.nvim_set_hl(0, "FlutterClosingTags", { fg = "#5C6370", italic = true })
	end,
})

-- Notification helper for Flutter commands
local function flutter_notify(message, level)
	vim.notify("[Flutter] " .. message, level or vim.log.levels.INFO)
end

-- Custom Flutter utility functions
_G.flutter_utils = {
	hot_reload = function()
		flutter_notify("Hot reloading...")
		vim.cmd("FlutterReload")
	end,
	
	hot_restart = function()
		flutter_notify("Hot restarting...")
		vim.cmd("FlutterRestart")
	end,
	
	quick_fix = function()
		flutter_notify("Running quick fix...")
		vim.lsp.buf.code_action()
	end,
	
	open_emulator = function()
		flutter_notify("Opening emulator...")
		vim.cmd("FlutterEmulators")
	end,
	
	clean_and_get = function()
		flutter_notify("Cleaning and getting dependencies...")
		vim.cmd("FlutterCleanAndGet")
	end,
	
	show_outline = function()
		flutter_notify("Toggling outline...")
		vim.cmd("FlutterOutlineToggle")
	end,
}

-- Success notification
flutter_notify("Flutter development environment loaded successfully! 🚀")
