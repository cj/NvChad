local M = {}

local lspconfig = require "lspconfig"

function isModuleAvailable(name)
   if package.loaded[name] then
      return true
   else
      for _, searcher in ipairs(package.searchers or package.loaders) do
         local loader = searcher(name)
         if type(loader) == "function" then
            package.preload[name] = loader
            return true
         end
      end
      return false
   end
end

local buf_augroup = function(name, event, fn)
   vim.api.nvim_exec(
      string.format(
         [[
    augroup %s
        autocmd! * <buffer>
        autocmd %s <buffer> %s
    augroup END
    ]],
         name,
         event,
         fn
      ),
      false
   )
end

local command = function(name, fn)
   vim.cmd(string.format("command! %s %s", name, fn))
end

local get_map_options = function(custom_options)
   local options = { noremap = true, silent = true }
   if custom_options then
      options = vim.tbl_extend("force", options, custom_options)
   end
   return options
end

local lua_command = function(name, fn)
   command(name, "lua " .. fn)
end

local buf_map = function(mode, target, source, opts, bufnr)
   vim.api.nvim_buf_set_keymap(bufnr, mode, target, source, get_map_options(opts))
end

local function on_attach(client, bufnr)
   local function buf_set_option(...)
      vim.api.nvim_buf_set_option(bufnr, ...)
   end

   -- Enable completion triggered by <c-x><c-o>
   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

   -- commands
   command("LspRef", "Telescope lsp_references")
   command("LspDef", "Telescope lsp_definitions")
   command("LspSym", "Telescope lsp_document_symbols")
   command("LspAct", "Telescope lsp_code_actions")
   command("LspAct", "Telescope lsp_code_actions")

   lua_command("LspPeekDef", "global.lsp.peek_definition()")
   lua_command("LspFormatting", "vim.lsp.buf.formatting()")
   lua_command("LspHover", "vim.lsp.buf.hover()")
   lua_command("LspRename", "vim.lsp.buf.rename()")
   lua_command("LspTypeDef", "vim.lsp.buf.type_definition()")
   lua_command("LspImplementation", "vim.lsp.buf.implementation()")
   lua_command("LspDiagPrev", "global.lsp.prev_diagnostic()")
   lua_command("LspDiagNext", "global.lsp.next_diagnostic()")
   lua_command("LspDiagLine", 'vim.lsp.diagnostic.show_line_diagnostics({ border = "single" })')
   lua_command("LspSignatureHelp", "vim.lsp.buf.signature_help()")

   -- bindings
   -- buf_map("n", "gh", ":LspPeekDef<CR>", nil, bufnr)
   -- buf_map("n", "gy", ":LspTypeDef<CR>", nil, bufnr)
   -- buf_map("n", "gi", ":LspRename<CR>", nil, bufnr)
   -- buf_map("n", "K", ":LspHover<CR>", nil, bufnr)
   -- buf_map("n", "[a", ":LspDiagPrev<CR>", nil, bufnr)
   -- buf_map("n", "]a", ":LspDiagNext<CR>", nil, bufnr)
   -- buf_map("i", "<C-x><C-x>", "<cmd> LspSignatureHelp<CR>", nil, bufnr)

   -- u.buf_augroup("LspAutocommands", "CursorHold", "LspDiagLine")

   -- u.buf_augroup("LspAutocommands", "BufEnter", "let b:illuminate_enabled=1")

   if not client.resolved_capabilities.formatting then
      buf_augroup("LspFormatOnSave", "BufWritePre", "lua vim.lsp.buf.formatting_sync(nil, 5000)")
   end

   -- require("illuminate").on_attach(client)

   -- telescope
   -- buf_map("n", "ga", ":LspAct<CR>", nil, bufnr)
   -- buf_map("n", "gr", ":LspRef<CR>", nil, bufnr)
   -- buf_map("n", "gd", ":LspDef<CR>", nil, bufnr)
end

local dlsconfig = require "diagnosticls-configs"
local reek = require "diagnosticls-configs.linters.reek"
-- local prettier = require "diagnosticls-configs.formatters.prettier"

dlsconfig.setup {
   ["ruby"] = {
      linter = reek,
   },
}

dlsconfig.init {
   -- Your custom attach function
   on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false

      -- Run nvchad's attach
      on_attach(client, bufnr)
   end,
}

M.setup_lsp = function(attach, capabilities)
   local lsp_installer = require "nvim-lsp-installer"

   vim.diagnostic.config {
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
   }

   lsp_installer.on_server_ready(function(server)
      local opts = {
         capabilities = capabilities,
         flags = {
            debounce_text_changes = 150,
         },
         settings = {},
      }

      opts.on_attach = function(client, bufnr)
         -- attach(client, bufnr)
         on_attach(client, bufnr)
      end

      if server.name == "jsonls" then
         opts.on_attach = function(client, bufnr)
            -- disable tsserver formatting if you plan on formatting via null-ls
            client.resolved_capabilities.document_formatting = false
            client.resolved_capabilities.document_range_formatting = false

            on_attach(client, bufnr)
         end
      end

      if server.name == "tsserver" then
         opts.init_options = require("nvim-lsp-ts-utils").init_options
         --
         opts.on_attach = function(client, bufnr)
            -- disable tsserver formatting if you plan on formatting via null-ls
            client.resolved_capabilities.document_formatting = false
            client.resolved_capabilities.document_range_formatting = false

            local ts_utils = require "nvim-lsp-ts-utils"

            -- defaults
            ts_utils.setup {
               debug = false,
               disable_commands = false,
               enable_import_on_completion = true,

               -- import all
               import_all_timeout = 5000, -- ms
               -- lower numbers indicate higher priority
               import_all_priorities = {
                  same_file = 1, -- add to existing import statement
                  local_files = 2, -- git files or files with relative path markers
                  buffer_content = 3, -- loaded buffer content
                  buffers = 4, -- loaded buffer names
               },
               import_all_scan_buffers = 100,
               import_all_select_source = false,

               -- eslint
               eslint_enable_code_actions = true,
               eslint_enable_disable_comments = true,
               eslint_bin = "eslint_d",
               eslint_enable_diagnostics = true,
               -- eslint_enable_formatting = false,
               eslint_opts = {},

               -- formatting
               enable_formatting = false,
               formatter = "prettierd",
               formatter_opts = {},

               -- update imports on file move
               update_imports_on_move = false,
               require_confirmation_on_move = false,
               watch_dir = nil,

               -- filter diagnostics
               filter_out_diagnostics_by_severity = {},
               filter_out_diagnostics_by_code = {},

               -- inlay hints
               auto_inlay_hints = false,
               inlay_hints_highlight = "Comment",
            }

            -- required to fix code action ranges and filter diagnostics
            ts_utils.setup_client(client)

            -- no default maps, so you may want to define some here
            -- local opts = { silent = true }

            on_attach(client, bufnr)

            -- require("navigator.lspclient.attach").on_attach(client, bufnr)

            -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
            -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", opts)
            -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportAll<CR>", opts)
         end
      end

      if server.name == "eslint" then
         opts.on_attach = function(client, bufnr)
            if isModuleAvailable "navigator.lspclient.attach" then
               require("navigator.lspclient.attach").on_attach(client, bufnr)
            end

            -- Run nvchad's attach
            on_attach(client, bufnr)
         end
      end

      if server.name == "solargraph" then
         opts.cmd = { "/home/cj/.asdf/shims/solargraph", "stdio" }

         opts.on_attach = function(client, bufnr)
            require("navigator.lspclient.attach").on_attach(client, bufnr)

            -- Run nvchad's attach
            on_attach(client, bufnr)
         end
      end

      if server.name == "pylsp" then
         opts.on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = true

            require("navigator.lspclient.attach").on_attach(client, bufnr)
            -- Run nvchad's attach
            on_attach(client, bufnr)
         end

         opts.settings = {
            pylsp = {
               plugins = {
                  jedi_definition = {
                     enabled = false,
                  },
                  jedi_references = {
                     enabled = false,
                  },
                  jedi_symbols = {
                     enabled = false,
                  },
               },
            },
         }
      end

      if server.name == "diagnosticls" then
         opts.on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = false

            -- Run nvchad's attach
            on_attach(client, bufnr)
         end
      end

      if server.name == "tailwindcss" then
         opts.settings = {
            tailwindCSS = {
               lint = {
                  cssConflict = "warning",
                  invalidApply = "error",
                  invalidConfigPath = "error",
                  invalidScreen = "error",
                  invalidTailwindDirective = "error",
                  invalidVariant = "error",
                  recommendedVariantOrder = "warning",
               },
               validate = true,
               experimental = {
                  classRegex = { "tw\\.\\w+`([^`]*)" },
               },
            },
         }
         opts.on_attach = function(client, bufnr)
            client.resolved_capabilities.document_formatting = false

            -- Run nvchad's attach
            on_attach(client, bufnr)
         end
      end

      if server.name == "graphql" then
         opts.settings = {
            format = { enable = true }, -- this will enable formatting
         }
      end

      server:setup(opts)

      vim.cmd [[ do User LspAttachBuffers ]]
   end)
end

return M
