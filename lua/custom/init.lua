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
