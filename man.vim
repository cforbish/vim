" vi:set sts=4 sw=4 ts=8 ft=vim et:
"
" tar
command! -nargs=* Man :call <SID>ManSection(<f-args>)
nmap K :call <SID>ManWord()<CR>

function! s:DoTestWin()
    echo 'type is ' . &ft
endfunction

function! s:GotoWin(id)
    let rc=0
    let wnum=0
    let type=''
    if match(a:id, '^\d\+$')
        let type=a:id
    else
        let wnum=a:id
    endif
    for wn in range(winnr('$'))
        if wnum
            if wnum == winnr()
                let rc=winnr()
                break
            endif
        else
            if &ft == 'man'
                let rc=winnr()
                break
            endif
        endif
        exec "normal \<c-w>w"
    endfor
    return rc
endfunction

function! s:ManLaunch(section, symbol)
    let l:savelz=&lz
    set lz
    let l:savemore=&more
    set nomore
    let mn=<SID>GotoWin('man')
    setl modifiable
    if mn
        %d
    else
        vert new
        set nomore
    endif
    if a:section == 0
        " sil! exec 'r !man -P cat ' . a:symbol . ' | col -b'
        sil! exec 'r !man ' . a:symbol . ' | col -b'
    else
        " sil! exec 'r !man -P cat ' . a:section . ' ' . a:symbol . ' | col -b'
        sil! exec 'r !man ' . a:section . ' ' . a:symbol . ' | col -b'
    endif
    sil! exec 'file ' . a:symbol . '.' . a:section
    1d
    " nnoremap <buffer> <c-]> :call <SID>ManWord()<CR>
    " nnoremap <buffer> <c-t> :call <SID>PopPage()<CR>
    setl nomodifiable nomodified ft=man
    let &more=l:savemore
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

