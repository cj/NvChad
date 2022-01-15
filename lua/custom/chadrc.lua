-- This is an example chadrc file , its supposed to be placed in /lua/custom dir
-- lua/custom/chadrc.lua

local M = {}
M.options, M.ui, M.mappings, M.plugins = {}, {}, {}, {}

vim.cmd [[
  let g:copilot_no_tab_map = v:true
  let g:copilot_assume_mapped = v:true
  let g:copilot_filetypes = {
                  \ 'guihua': v:false,
                  \ 'telescope': v:false,
                  \ }
  set pumblend=20
]]

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.options = {
   mapleader = ";",
}

M.ui = {
   italic_comments = true,
}

M.plugins = {
   default_plugin_config_replace = {
      nvim_tree = "custom.configs.nvimtree",
      telescope = "custom.configs.telescope",
      nvim_cmp = "custom.configs.cmp",
      nvim_treesitter = "custom.configs.treesitter",
   },
   status = {
      -- comment = false,
      dashboard = true,
      colorizer = true, -- color RGB, HEX, CSS, NAME color codes
   },
   options = {
      lspconfig = {
         setup_lspconf = "custom.configs.lspconf", -- path of file containing setups of different lsps
      },
      nvimtree = {
         enable_git = 0,
         -- packerCompile required after changing lazy_load
         lazy_load = true,

         ui = {
            allow_resize = true,
            side = "left",
            width = 25,
            hide_root_folder = true,
            mappings = {},
         },
      },
      autopairs = {
         loadAfter = "nvim-cmp",
         disable_filetype = { "TelescopePrompt", "guihua", "guihua_rust", "clap_input" },
      },
   },
}

M.mappings.plugins = {
   comment = {
      toggle = "<leader> ",
   },
   nvimtree = {
      toggle = "<leader>e",
      focus = "<leader>E",
   },
   lspconfig = {
      declaration = "zz",
      definition = "zz",
      hover = "zz",
      implementation = "zz",
      signature_help = "zz",
      add_workspace_folder = "zz",
      remove_workspace_folder = "zz",
      list_workspace_folders = "zz",
      type_definition = "zz",
      rename = "zz",
      code_action = "zz",
      references = "zz",
      float_diagnostics = "zz",
      goto_prev = "zz",
      goto_next = "zz",
      set_loclist = "zz",
      formatting = "zz",
   },
   telescope = {
      buffers = "<leader>b",
      find_files = "<leader>f",
      find_hiddenfiles = "<leader>F",
      git_commits = "<leader>cm",
      git_status = "<leader>gt",
      help_tags = "<leader>th",
      live_grep = "<leader>t",
      oldfiles = "<leader>r",
      themes = "zz", -- NvChad theme picker
      -- media previews within telescope finders
      telescope_media = {
         media_files = "<leader>m",
      },
   },
}

return M
