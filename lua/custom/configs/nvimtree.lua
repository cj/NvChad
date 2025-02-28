local tree_cb = require("nvim-tree.config").nvim_tree_callback

local present, nvimtree = pcall(require, "nvim-tree")

local conf = require("core.utils").load_config().plugins.options.nvimtree

local git_status = conf.enable_git
local ui = conf.ui

if not present then
   return
end

local g = vim.g

g.nvim_tree_add_trailing = 0 -- append a trailing slash to folder names
g.nvim_tree_git_hl = git_status
g.nvim_tree_highlight_opened_files = 0
g.nvim_tree_indent_markers = 1
g.nvim_tree_quit_on_open = 0 -- closes tree when file's opened
g.nvim_tree_root_folder_modifier = table.concat { ":t:gs?$?/..", string.rep(" ", 1000), "?:gs?^??" }

g.nvim_tree_window_picker_exclude = {
   filetype = { "notify", "packer", "qf" },
   buftype = { "terminal" },
}

g.nvim_tree_show_icons = {
   folders = 1,
   files = 1,
   git = git_status,
}

g.nvim_tree_icons = {
   default = "",
   symlink = "",
   git = {
      deleted = "",
      ignored = "◌",
      renamed = "➜",
      staged = "✓",
      unmerged = "",
      unstaged = "✗",
      untracked = "★",
   },
   folder = {
      default = "",
      empty = "",
      empty_open = "",
      open = "",
      symlink = "",
      symlink_open = "",
   },
}

nvimtree.setup {
   filters = {
      dotfiles = false,
   },
   disable_netrw = true,
   hijack_netrw = true,
   ignore_ft_on_setup = { "dashboard" },
   auto_close = false,
   open_on_tab = false,
   hijack_cursor = true,
   update_cwd = true,
   update_focused_file = {
      enable = true,
      update_cwd = false,
   },
   view = {
      allow_resize = true,
      side = "left",
      width = 25,
      hide_root_folder = true,
      mappings = {
         list = {
            { key = { "<CR>", "o", "<2-LeftMouse>" }, cb = tree_cb "edit" },
            { key = { "<2-RightMouse>", "<C-}>" }, cb = tree_cb "cd" },
            { key = { "<C-v>", "sg" }, cb = tree_cb "vsplit" },
            { key = { "<C-x>", "sv" }, cb = tree_cb "split" },
            { key = "<C-t>", cb = tree_cb "tabnew" },
            { key = "<", cb = tree_cb "prev_sibling" },
            { key = ">", cb = tree_cb "next_sibling" },
            { key = "P", cb = tree_cb "parent_node" },
            { key = "l", cb = tree_cb "open_node" },
            { key = "<BS>", cb = tree_cb "close_node" },
            { key = { "<S-CR>", "h" }, cb = tree_cb "close_node" },
            { key = "<Tab>", cb = tree_cb "preview" },
            { key = "K", cb = tree_cb "first_sibling" },
            { key = "J", cb = tree_cb "last_sibling" },
            { key = "I", cb = tree_cb "toggle_ignored" },
            { key = "H", cb = tree_cb "toggle_dotfiles" },
            { key = "R", cb = tree_cb "refresh" },
            { key = "a", cb = tree_cb "create" },
            { key = "d", cb = tree_cb "remove" },
            { key = "r", cb = tree_cb "rename" },
            { key = "<C->", cb = tree_cb "full_rename" },
            { key = "x", cb = tree_cb "cut" },
            { key = "c", cb = tree_cb "copy" },
            { key = "p", cb = tree_cb "paste" },
            { key = "y", cb = tree_cb "copy_name" },
            { key = "Y", cb = tree_cb "copy_path" },
            { key = "gy", cb = tree_cb "copy_absolute_path" },
            { key = "[c", cb = tree_cb "prev_git_item" },
            { key = "}c", cb = tree_cb "next_git_item" },
            { key = "-", cb = tree_cb "dir_up" },
            { key = "q", cb = tree_cb "close" },
            { key = "g?", cb = tree_cb "toggle_help" },
         },
      },
   },
   git = {
      ignore = false,
   },
}
