local null_ls = require "null-ls"
local b = null_ls.builtins

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

local sources = {

   -- b.formatting.deno_fmt,

   b.formatting.prettierd.with {
      filetypes = { "html", "json", "yaml", "markdown", "lua", "graphql" },
   },

   b.formatting.eslint_d.with {
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
   },

   b.diagnostics.eslint_d.with {
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
   },

   -- Lua
   b.formatting.stylua,
   b.diagnostics.luacheck.with { extra_args = { "--global vim" } },

   -- Shell
   b.formatting.shfmt,
   b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },
}

local M = {}

M.setup = function()
   null_ls.setup {
      -- debug = true,
      sources = sources,

      -- format on save
      on_attach = function(client, bufnr)
         client.resolved_capabilities.document_formatting = true
      end,
   }
end

return M
