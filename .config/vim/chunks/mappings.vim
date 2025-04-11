vim9script
g:mapleader = ' '

# Base ........................................{{{
# nmap <Leader>x : echo "Leader x pressed!"<CR>
nmap <Leader>x <Plug>StripTrailingWhitespace

# Move while insert
inoremap <C-h> <Left>
inoremap <C-l> <Right>
inoremap <C-j> <Down>
inoremap <C-k> <Up>

# Insert newline
nmap o] o<esc>
nmap o[ O<esc>

# Delete right in insert mode
inoremap <C-d> <C-o>x

# Shorter escape
inoremap jk <esc>l

# Enable proper navigation in netrw
nmap <kEnter> <Enter>

# Enter command mode in normal mode
nnoremap ; :
# }}}

# vim-tmux-navigator--------------------------- {{{
g:tmux_navigator_no_mappings = 1
nnoremap <silent> <c-h> : <C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <c-j> : <C-U>TmuxNavigateDown<cr>
nnoremap <silent> <c-k> : <C-U>TmuxNavigateUp<cr>
nnoremap <silent> <c-l> : <C-U>TmuxNavigateRight<cr>
# }}}
