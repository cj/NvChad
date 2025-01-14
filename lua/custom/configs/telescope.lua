local present, telescope = pcall(require, "telescope")

if not present then
   return
end

local actions = require "telescope.actions"

telescope.setup {
   defaults = {
      vimgrep_arguments = {
         "rg",
         "--color=never",
         "--no-heading",
         "--with-filename",
         "--line-number",
         "--column",
         "--smart-case",
      },
      prompt_prefix = "   ",
      selection_caret = "  ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
         horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
         },
         vertical = {
            mirror = false,
         },
         width = 0.87,
         height = 0.80,
         preview_cutoff = 120,
      },
      file_sorter = require("telescope.sorters").get_fuzzy_file,
      file_ignore_patterns = { "node_modules" },
      generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
      path_display = { "truncate" },
      winblend = 0,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
      file_previewer = require("telescope.previewers").vim_buffer_cat.new,
      grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
      qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
      -- Developer configurations: Not meant for general override
      buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
      mappings = {
         i = {
            ["<C-c>"] = actions.close,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- ["<c-t>"] = trouble.open_with_trouble,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            -- To disable a keymap, put [map] = false
            -- So, to not map "<C-n>", just put
            -- ["<c-x>"] = false,
            -- ["<esc>"] = actions.close,

            -- Otherwise, just set the mapping to the function that you want it to be.
            -- ["<C-i>"] = actions.select_horizontal,

            -- Add up multiple actions
            ["<CR>"] = actions.select_default + actions.center,

            -- You can perform as many actions in a row as you like
            -- ["<CR>"] = actions.select_default + actions.center + my_cool_custom_action,
         },
         n = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- ["<c-t>"] = trouble.open_with_trouble,
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            -- ["<C-i>"] = my_cool_custom_action,
         },
      },
   },
   extensions = {
      fzf = {
         fuzzy = true, -- false will only do exact matching
         override_generic_sorter = false, -- override the generic sorter
         override_file_sorter = true, -- override the file sorter
         case_mode = "smart_case", -- or "ignore_case" or "respect_case"
         -- the default case_mode is "smart_case"
      },
      media_files = {
         filetypes = { "png", "webp", "jpg", "jpeg" },
         find_cmd = "rg", -- find command (defaults to `fd`)
      },
   },
}

local extensions = { "themes", "terms", "fzf", "neoclip" }
local packer_repos = [["extensions", "telescope-fzf-native.nvim"]]

if vim.fn.executable "ueberzug" == 1 then
   table.insert(extensions, "media_files")
   packer_repos = packer_repos .. ', "telescope-media-files.nvim"'
end

pcall(function()
   for _, ext in ipairs(extensions) do
      telescope.load_extension(ext)
   end
end)
