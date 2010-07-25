" vi:set ts=3 sts=3 sw=3 ft=vim et:
"
" This file stolen and hacked from $VIMRUNTIME/ftplugin/man.vim
" Vim filetype plugin file
" Language:     man
" Maintainer:   Nam SungHyun <namsh@kldp.org>
" Last Change:  2001 Sep 20

" To make the ":Man" command available before editing a manual page, source
" this script from your startup vimrc file.

" If 'filetype' isn't "man", we must have been called to only define ":Man".
if &filetype == "man"
  " Only do this when not done yet for this buffer
  if exists("b:did_ftplugin")
    finish
  endif
  let b:did_ftplugin = 1
  " allow dot in manual page name.
  setlocal iskeyword+=\.
  " Add mappings, unless the user didn't want this.
  if !exists("no_plugin_maps") && !exists("no_man_maps")
    if !hasmapto('<Plug>ManBS')
      nmap <buffer> <LocalLeader>h <Plug>ManBS
    endif
    nnoremap <buffer> <Plug>ManBS :%s/.\b//g<CR>:set nomod<CR>''
    nnoremap <buffer> <c-]> :call ManPreGetPage(v:count)<CR>
    nnoremap <buffer> <c-t> :call <SID>PopPage()<CR>
  endif
endif

com! -nargs=1 Man call s:GetPage(<f-args>)
" nmap <Leader>K :call <SID>:PreGetPage(0)<CR>
nmap K :call ManPreGetPage(0)<CR>

if !exists("s:man_tag_depth")
  let s:man_tag_depth = 0
endif

if $OSTYPE =~ "solaris"
  let s:man_sect_arg = "-s"
  let s:man_find_arg = "-l"
else
  let s:man_sect_arg = ""
  let s:man_find_arg = "-w"
endif

func! ManPreGetPage(cnt)
  if (a:cnt == 0)
    let l:str = expand("<cWORD>")
    let l:page = substitute(l:str, '(.*', '', '')
    let l:sect = substitute(l:str, '.*(\(.*\))', '\1', '')
    if (match(l:sect, '^[0-9 ]\+$') == -1)
      let l:sect = ""
    endif
    if (l:sect == l:page)
      let l:sect = ""
    endif
  else
    let l:sect = a:cnt
    let l:page = expand("<cword>")
  endif
  call s:GetPage(l:sect, l:page)
endfunc

func! <SID>GetCmdArg(sect, page)
  if a:sect == ''
    return a:page
  endif
  return s:man_sect_arg.' '.a:sect.' '.a:page
endfunc

func! <SID>BuildPage(sect, page)
  %d
  silent exec "r !man ".s:GetCmdArg(a:sect, a:page)." | col -b"
  sil! normal 1Gdd
  sil! g;^xxx;d
  let l:pattern = expand("<cWORD>")
  exec "sil! s;" . l:pattern . ";\\L&\\E;g"
  let l:retval = strlen(getline(1))
  return l:retval
endfunc

func! <SID>GetPage(...)
   let l:lz = &lz
   set lz
  if a:0 >= 2
    let sect = a:1
    let page = a:2
  elseif a:0 >= 1
    let sect = ""
    let page = a:1
  else
    return
  endif
  " To support: nmap K :Man <cword>
  if page == '<cword>'
    let page = expand('<cword>')
  endif
  exec "let s:man_tag_buf_".s:man_tag_depth." = ".bufnr("%")
  exec "let s:man_tag_lin_".s:man_tag_depth." = ".line(".")
  exec "let s:man_tag_col_".s:man_tag_depth." = ".col(".")
  let s:man_tag_depth = s:man_tag_depth + 1
  " Use an existing "man" window if it exists, otherwise open a new one.
  if &filetype != "man"
    let thiswin = winnr()
    exe "norm! \<C-W>b"
    if winnr() == 1
      vert new
    else
      exe "norm! " . thiswin . "\<C-W>w"
      while 1
        if &filetype == "man"
          sil! 0file!
          break
        endif
        exe "norm! \<C-W>w"
        if thiswin == winnr()
          vert new
          break
        endif
      endwhile
    endif
  endif
  set modifiable
  %d
  let $MANWIDTH = winwidth(0)
  let l:havepage = 1
  if (s:BuildPage(sect, page) < 2)
    if (s:BuildPage('', page) < 2)
      bw!
      echohl WarningMsg
      echo "\nCannot find " . page . "(" . sect . ")."
      echohl None
      let l:havepage = 0
    endif
  endif
  if (l:havepage)
    let l:rpage = substitute(getline(1), '(.*', '', '')
    let l:rsect = substitute(getline(1), '.*(\([^)]*\)).*', '\1', '')
    execute "sil! file ~/vimtmp/" . l:rpage . "_" . l:rsect . ".man"
    sil! update!
    setl ft=man nomod
    " setl bufhidden=hide
    setl nobuflisted
    setl ts=8
    setl sw=8
    setl sts=8
    setl nomodifiable
  endif
   if (l:lz)
      set lz
   else
      set nolz
   endif
endfunc

func! <SID>PopPage()
  if s:man_tag_depth > 0
    let s:man_tag_depth = s:man_tag_depth - 1
    exec "let s:man_tag_buf=s:man_tag_buf_".s:man_tag_depth
    exec "let s:man_tag_lin=s:man_tag_lin_".s:man_tag_depth
    exec "let s:man_tag_col=s:man_tag_col_".s:man_tag_depth
    exec s:man_tag_buf."b"
    exec s:man_tag_lin
    exec "norm ".s:man_tag_col."|"
    exec "unlet s:man_tag_buf_".s:man_tag_depth
    exec "unlet s:man_tag_lin_".s:man_tag_depth
    exec "unlet s:man_tag_col_".s:man_tag_depth
    unlet s:man_tag_buf s:man_tag_lin s:man_tag_col
  endif
endfunc

" vim: set sw=2:
