-- This is an example init file , its supposed to be placed in /lua/custom dir
-- lua/custom/init.lua

-- This is where your custom modules and plugins go.
-- Please check NvChad docs if you're totally new to nvchad + dont know lua!!

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

-- MAPPINGS
-- To add new plugins, use the "setup_mappings" hook,

-- hooks.override("lsp", "publish_diagnostics", function(current)
--    current.virtual_text = false
--
--    return current
-- end)

local map = require("core.utils").map

vim.o.history = 10000
vim.o.undolevels = 10000
vim.o.undofile = true

local opts = { noremap = true, silent = true }

map("n", "U", "<c-r>", opts)
map("n", "W", ":write<cr>", opts)
map("n", "Q", ":bd<CR>", opts)
map("n", "Y", "yy", opts)
map("n", "sv", ":<C-u>split<CR>", opts)
map("n", "sg", ":<C-u>vsplit<CR>", opts)
map("n", "gd", ":Telescope lsp_definitions<CR>", opts)
map("n", "<Space>", "<cmd>lua require'hop'.hint_words()<cr>", {})
map("n", "T", ":LspTrouble<CR>", opts)
map("n", "<leader>d", ":LspSym<CR>", opts)
map("n", "<leader>D", ":TroubleToggle document_diagnostics<CR>", opts)
-- map("n", "M", ":LspAct<cr>", opts)
map("n", "D", ":LspDiagLine<CR>", opts)
map("n", "<leader>y", ":Telescope neoclip<CR>", opts)
-- map("n", "R", "<cmd>lua require'telescope.builtin'.planets{}", opts)
-- map("n", "]", ":LspDiagNext<CR>", opts)
-- map("n", "[", ":LspDiagPrev<CR>", opts)
-- map("n", "]", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
-- map("n", "[", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
map("n", "<Leader>T", "<cmd>lua require'telescope.builtin'.grep_string{}<cr>", opts)
map("n", "<Leader>R", "<cmd>lua require'telescope.builtin'.resume{}<cr>", opts)

vim.cmd [[
    set cmdheight=2
    set shortmess=AsIF

    imap <silent><script><expr> <C-e> copilot#Accept("\<CR>")

    hi matchword cterm=underline gui=underline
    hi LspReferenceRead cterm=none gui=none guifg=none guibg=none
    hi LspReferenceText cterm=none gui=none guifg=none guibg=none
    hi LspReferenceWrite cterm=none gui=none guifg=none guibg=none

    augroup illuminate_augroup
      autocmd!
      autocmd vimenter * hi illuminatedword cterm=underline gui=underline
    augroup end

    map <silent> <enter> :noh<cr>

    " Zoom
    function! s:zoom()
      if winnr('$') > 1
        tab split
      elseif len(filter(map(range(tabpagenr('$')), 'tabpagebuflist(v:val + 1)'),
            \ 'index(v:val, '.bufnr('').') >= 0')) > 1
        tabclose
      endif
    endfunction

    nnoremap <silent> <leader>z :call <sid>zoom()<cr>

    omap t <plug>(easymotion-bd-tl)
    vmap t <plug>(easymotion-bd-tl)
    map f <plug>(easymotion-fl)
    map f <plug>(easymotion-fl)

    autocmd User EasyMotionPromptBegin silent! LspStop
    autocmd User EasyMotionPromptEnd silent! LspStart

    " Show syntax highlighting groups for word under cursor
    nmap <F2> :call <SID>SynStack()<CR>
    function! <SID>SynStack()
        if !exists("*synstack")
            return
        endif
        echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    endfunc
]]

-- NOTE : opt is a variable  there (most likely a table if you want multiple options),
-- you can remove it if you dont have any custom options

-- Install plugins
-- To add new plugins, use the "install_plugin" hook,

-- examples below:

local jsfiles = { "javascript", "typescript", "javascriptreact", "typescriptreact", "graphql" }

local customPlugins = require "core.customPlugins"

customPlugins.add(function(use)
   use {
      "jose-elias-alvarez/nvim-lsp-ts-utils",
   }

   use { "christoomey/vim-tmux-navigator" }

   use {
      "phaazon/hop.nvim",
      event = "BufEnter",
      branch = "v1", -- optional but strongly recommended
      config = function()
         -- you can configure Hop the way you like here; see :h hop-config
         require("hop").setup {}
      end,
   }

   use { "williamboman/nvim-lsp-installer" }

   use { "roxma/vim-tmux-clipboard" }

   use {
      "jose-elias-alvarez/null-ls.nvim",
      after = "nvim-lspconfig",
      requires = "jose-elias-alvarez/nvim-lsp-ts-utils",
      config = function()
         require("custom.configs.null-ls").setup()
      end,
   }

   use { "editorconfig/editorconfig", event = "InsertEnter" }

   use { "mg979/vim-visual-multi", event = "InsertEnter" }

   use { "slim-template/vim-slim", ft = { "slim" } }

   use { "JoosepAlviste/nvim-ts-context-commentstring", after = "nvim-treesitter" }

   use {
      "jparise/vim-graphql",
      event = "InsertEnter",
      ft = jsfiles,
   }

   use {
      "windwp/nvim-ts-autotag",
      ft = jsfiles,
   }
   use { "kchmck/vim-coffee-script", ft = "coffee" }

   use {
      "folke/trouble.nvim",
      requires = "kyazdani42/nvim-web-devicons",
      event = "BufEnter",
      ft = { "javascript", "typescript", "javascriptreact", "typescriptreact", "graphql", "ruby" },
      config = function()
         require("trouble").setup {
            use_diagnostic_signs = true,
         }
      end,
   }

   use { "github/copilot.vim" }

   use { "RRethy/vim-illuminate" }

   use {
      "tzachar/cmp-tabnine",
      after = "nvim-cmp",
      requires = "hrsh7th/nvim-cmp",
      run = "./install.sh",
      config = function()
         local tabnine = require "cmp_tabnine.config"
         tabnine:setup {
            max_lines = 1000,
            max_num_results = 5,
            sort = true,
            run_on_every_keystroke = true,
            snippet_placeholder = "..",
         }
      end,
   }

   use {
      "hrsh7th/cmp-copilot",
      after = "nvim-cmp",
   }

   use {
      "creativenull/diagnosticls-configs-nvim",
      requires = { "neovim/nvim-lspconfig" },
   }

   use {
      "easymotion/vim-easymotion",
      event = "BufEnter",
      config = function() end,
   }

   use { "mbbill/undotree" }

   use {
      "AckslD/nvim-neoclip.lua",
      config = function()
         require("neoclip").setup {
            history = 1000,
            enable_persistant_history = false,
            db_path = vim.fn.stdpath "data" .. "/databases/neoclip.sqlite3",
            filter = nil,
            preview = true,
            default_register = '"',
            content_spec_column = false,
            on_paste = {
               set_reg = false,
            },
            keys = {
               telescope = {
                  i = {
                     select = "<cr>",
                     paste = "<c-p>",
                     paste_behind = "<c-k>",
                     custom = {},
                  },
                  n = {
                     select = "<cr>",
                     paste = "p",
                     paste_behind = "P",
                     custom = {},
                  },
               },
               fzf = {
                  select = "default",
                  paste = "ctrl-p",
                  paste_behind = "ctrl-k",
                  custom = {},
               },
            },
         }
      end,
   }

   use {
      "rcarriga/nvim-notify",
      config = function()
         vim.notify = require "notify"
      end,
   }

   use {
      "folke/todo-comments.nvim",
      requires = "nvim-lua/plenary.nvim",
      config = function()
         require("todo-comments").setup {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
         }
      end,
   }

   use { "tpope/vim-abolish" }

   use {
      "ray-x/navigator.lua",
      requires = { "cj/guihua.lua", run = "cd lua/fzy && make" },
      -- commit = "5b2e003258bc73ecaf3192090419ac8e95d60680",
      config = function()
         require("navigator").setup {
            -- keymaps = {{key = "gK", func = "declaration()"}},
            default_mapping = false,
            transparency = 100,
            keymaps = {
               { key = "gr", func = "require('navigator.reference').reference()" },
               { key = "Gr", func = "require('navigator.reference').async_ref()" },
               { mode = "i", key = "<M-k>", func = "signature_help()" },
               -- { key = "<c-k>", func = "signature_help()" },
               { key = "g0", func = "require('navigator.symbols').document_symbols()" },
               { key = "gW", func = "require('navigator.workspace').workspace_symbol()" },
               { key = "<c-]>", func = "require('navigator.definition').definition()" },
               { key = "gD", func = "declaration({ border = 'rounded', max_width = 80 })" },
               { key = "gp", func = "require('navigator.definition').definition_preview()" },
               { key = "gt", func = "require('navigator.treesitter').buf_ts()" },
               { key = "<Leader>gt", func = "require('navigator.treesitter').bufs_ts()" },
               -- { key = "K", func = "hover({ popup_opts = { border = single, max_width = 80 }})" },
               { key = "K", func = "vim.lsp.buf.hover()" },
               { key = "M", mode = "n", func = "require('navigator.codeAction').code_action()" },
               { key = "<Leader>cA", mode = "v", func = "range_code_action()" },
               -- { key = '<Leader>re', func = 'rename()' },
               { key = "<Leader>rn", func = "require('navigator.rename').rename()" },
               { key = "<Leader>gi", func = "incoming_calls()" },
               { key = "<Leader>go", func = "outgoing_calls()" },
               { key = "gi", func = "implementation()" },
               -- { key = "<Space>D", func = "type_definition()" },
               { key = "D", func = "require('navigator.diagnostics').show_diagnostics()" },
               { key = "gG", func = "require('navigator.diagnostics').show_buf_diagnostics()" },
               { key = "<Leader>dt", func = "require('navigator.diagnostics').toggle_diagnostics()" },
               { key = "]d", func = "diagnostic.goto_next({ border = 'rounded', max_width = 80})" },
               { key = "[d", func = "diagnostic.goto_prev({ border = 'rounded', max_width = 80})" },
               { key = "]r", func = "require('navigator.treesitter').goto_next_usage()" },
               { key = "[r", func = "require('navigator.treesitter').goto_previous_usage()" },
               { key = "<C-LeftMouse>", func = "definition()" },
               { key = "g<LeftMouse>", func = "implementation()" },
               -- { key = "<Leader>k", func = "require('navigator.dochighlight').hi_symbol()" },
               -- { key = "<Space>wa", func = "require('navigator.workspace').add_workspace_folder()" },
               -- { key = "<Space>wr", func = "require('navigator.workspace').remove_workspace_folder()" },
               -- { key = "<Space>ff", func = "formatting()", mode = "n" },
               -- { key = "<Space>ff", func = "range_formatting()", mode = "v" },
               -- { key = "<Space>wl", func = "require('navigator.workspace').list_workspace_folders()" },
               -- { key = "<Space>la", mode = "n", func = "require('navigator.codelens').run_action()" },
            },
            lsp_installer = true,
            lsp_signature_help = true,
            -- signature_help_cfg = {
            --    debug = false, -- virtual hint enable
            --    bind = true,
            -- },
            lsp = {
               disable_lsp = {
                  "jsonls",
                  "angularls",
                  "denols",
                  "sumneko_lua",
                  "yamlls",
                  "bashls",
                  "pylsp",
                  "sqls",
                  "jedi_language_server",
                  "null-ls",
               },
               diagnostic_virtual_text = false,
               format_on_save = false,
               code_lens = true,
               tsserver = { -- gopls setting
                  on_attach = function(client, bufnr) -- on_attach for gopls
                     client.resolved_capabilities.document_formatting = false
                  end,
               },
               -- display_diagnostic_qf = true,
               code_action = {
                  enable = true,
                  sign = true,
                  sign_priority = 40,
                  virtual_text = false,
               },
               code_lens_action = {
                  enable = true,
                  sign = true,
                  sign_priority = 20,
                  virtual_text = false,
               },
            },
         }

         vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            underline = true,
            virtual_text = false,
            update_in_insert = true,
         })

         vim.cmd [[
           hi default GHTextViewDark guifg=#e0d8f4 guibg=#332e55
           hi default GHListDark guifg=#e0d8f4 guibg=#103234
           hi default GHListHl guifg=#e0d8f4 guibg=#404254
         ]]
         -- vim.cmd "autocmd BufWritePre *.rb,*.py,*.graphql,*.gql lua vim.lsp.buf.formatting_sync()"

         -- vim.cmd "autocmd FileType guihua lua require('cmp').setup.buffer { enabled = false }"
         -- vim.cmd "autocmd FileType guihua_rust lua require('cmp').setup.buffer { enabled = false }"
         --
         -- if vim.o.ft == "clap_input" and vim.o.ft == "guihua" and vim.o.ft == "guihua_rust" then
         --    require("cmp").setup.buffer { completion = { enable = false } }
         -- end
         -- vim.cmd [[
         --   hi default GHTextViewDark guifg=#e0d8f4 guibg=#332e55
         --   hi default GHListDark guifg=#e0d8f4 guibg=#103234
         --   hi default GHListHl guifg=#e0d8f4 guibg=#404254
         -- ]]
      end,
   }
end)

-- NOTE: we heavily suggest using Packer's lazy loading (with the 'event' field)
-- see: https://github.com/wbthomason/packer.nvim
-- https://nvchad.github.io/config/walkthrough
