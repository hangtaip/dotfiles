vim9script
def StripTrailingWhitespace()
    if !&binary && &filetype != 'diff'
        normal mz
        normal Hmy
        %s/\s\+$//e
        normal 'yz<CR>
        normal `z
    endif
enddef
nnoremap <Plug>StripTrailingWhitespace: <C-U>call <SID>StripTrailingWhitespace()<CR>
