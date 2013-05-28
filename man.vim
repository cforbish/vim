" vi:set sts=4 sw=4 ts=8 ft=vim et:
"
let $MANPAGER=""
command! -nargs=* Man :call <SID>ManSection(<f-args>)
nmap K :call <SID>ManWord()<CR>

function! s:DoTestWin()
    echo 'type is ' . &ft
endfunction

function! s:ManLaunch(section, symbol)
    let l:savelz=&lz
    set lz
    windo if &ft == 'man' | sil! bw! | endif
    vert new
    set modifiable
    if a:section == 0
        sil! exec 'r !/usr/bin/man ' . a:symbol . ' | col -b'
    else
        sil! exec 'r !/usr/bin/man ' . a:section . ' ' . a:symbol . ' | col -b'
    endif
    sil! exec 'file ' . a:symbol . '.' . a:section
    1d
    " nnoremap <buffer> <c-]> :call <SID>ManWord()<CR>
    " nnoremap <buffer> <c-t> :call <SID>PopPage()<CR>
    set nomodifiable nomodified ft=man
    let &lz=l:savelz
endfunction

function! s:ManSection(...)
    if match(a:1, "[0-9]") == -1
        let l:section = 0
        let l:symbol = a:1
    else
        let l:section = a:1
        let l:symbol = a:2
    endif
    call s:ManLaunch(l:section, l:symbol)
endfunction

function! s:ManWord()
    let l:symbol = substitute(expand("<cWORD>"), '(.*', '', '')
    let l:section = substitute(expand("<cWORD>"), '.*(\(.*\))', '\1', '')
    call <SID>ManSection(l:section, l:symbol)
endfunction

