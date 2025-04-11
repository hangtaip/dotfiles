vim9script
# Disable compatibility with vi which can cause exexpected issues.
# set viminfo+='1000,n$XDG_CACHE_HOME/vim/.viminfo

# Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

# Enable plugins and load plugin for the detected file type.
filetype plugin on

# Load an indent file for the detected file type.
filetype indent on

# Change cursor shape
&t_SI = "\e[6 q"
&t_SR = "\e[4 q"
&t_EI = "\e[2 q"

# Set theme
set termguicolors
set rtp+=$XDG_CONFIG_HOME/vim/colors/tokyonight.nvim/extras/vim
colorscheme tokyonight

# Turn syntax highlighting on.
syntax on

# Add numbers to each line on the left-hand side.
# Set relative number
set number
set relativenumber

# Highlight cursor line underneath the cursor horizontally.
# set cursorline

# Highlight cursor line underneath the cursor vertically.
# set cursorcolumn

# Set shift width to 4 spaces.
set shiftwidth=4

# Set tab width to 4 columns.
set tabstop=4

# Use space characters instead of tabs.
set expandtab

# Set undofile
set undofile
set undolevels=1000
set undoreload=10000

# Do not save backup files.
set nobackup

# Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

# Do not wrap lines. Allow long lines to extend as far as the line goes.
set nowrap

# While searching through a file incrementally highlight matching charactersas you type.
set incsearch

# Ignore capital letters during search.
set ignorecase

# Override the ignorecase option if searching for capital letters.
# This will allow search specifically for capital letters.
set smartcase

# Show partial command typed in the last line of the screen.
set showcmd

# Show the mode you are on the last line.
set showmode

# Show matching words during a search.
set showmatch

# Use highlighting when doing a search.
set hlsearch

# Set the commands to save in history default number is 20.
set history=1000

# Set timeout for combined key maps
set timeoutlen=600

# Enable auto completion menu after pressing TAB.
set wildmenu

# Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

# There are certain files that we would never want to edit with Vim.
# Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

# Make backspace remove indent
set backspace=indent,eol,start

# Set yank to clipboard
set clipboard=unnamed,unnamedplus
# PLUGINS ---------------------------------------------------------------- {{{

# Plugin code goes here.
# Install vim-plug if not found
# if empty(glob($XDG_CONFIG_HOME .. '/vim/autoload/plug.vim'))
#     silent !curl -fLo $XDG_CONFIG_HOME .. '/vim/autoload.vim' --create-dirs
#     \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# endif
# 
# # Run PlugInstall if there are missing plugins
# autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) > 0
#     | PlugInstall --sync | source $MYVIMRC
#     | endif
# 
call plug#begin($XDG_CONFIG_HOME .. '/vim/plugged')
    Plug 'dense-analysis/ale'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
call plug#end()
# }}}


# MAPPINGS --------------------------------------------------------------- {{{

# Mappings code goes here.

# }}}


# VIMSCRIPT -------------------------------------------------------------- {{{

# This will enable code folding.
# Use the marker method of folding.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

# More Vimscripts code goes here.

# }}}


# STATUS LINE ------------------------------------------------------------ {{{

# Status bar code goes here.

# }}}
