" vi:set ts=2 sts=2 sw=2 et ft=vim:
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
  if a:cnt == 0
    let old_isk = &iskeyword
    setl iskeyword+=(,)
    let str = expand("<cword>")
    let &iskeyword = old_isk
    let page = substitute(str, '(*\(\k\+\).*', '\1', '')
    let sect = substitute(str, '\(\k\+\)(\([^()]*\)).*', '\2', '')
    if match(sect, '^[0-9 ]\+$') == -1
      let sect = ""
    endif
    if sect == page
      let sect = ""
    endif
  else
    let sect = a:cnt
    let page = expand("<cword>")
  endif
  call s:GetPage(sect, page)
endfunc

func! <SID>GetCmdArg(sect, page)
  if a:sect == ''
    return a:page
  endif
  return s:man_sect_arg.' '.a:sect.' '.a:page
endfunc

func! <SID>FindPage(sect, page)
  let where = system("/usr/bin/man ".s:man_find_arg.' '.s:GetCmdArg(a:sect, a:page))
  if where !~ "^/"
    if substitute(where, ".* \\(.*$\\)", "\\1", "") !~ "^/"
      return 0
    endif
  endif
  return 1
endfunc

func! <SID>BuildPage(sect, page)
  %d
  silent exec "r !man ".s:GetCmdArg(a:sect, a:page)." | col -b"
  sil! normal 1Gddgue
  sil! g;^xxx;d
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
  " if sect != "" && s:FindPage(sect, page) == 0
  "   let sect = ""
  " endif
  " if s:FindPage(sect, page) == 0
  "   echo "\nCannot find a '".page."'."
  "   return
  " endif
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
  " silent exec "r !/usr/bin/man ".s:GetCmdArg(sect, page)." | col -b"
  let l:havepage = 1
  if (s:BuildPage(sect, page) < 2)
    if (s:BuildPage('', page) < 2)
      echohl WarningMsg
      echo "\nCannot find " . page . "(" . sect . ")."
      echohl None
      let l:havepage = 0
      bw!
    endif
  endif
  if (l:havepage)
    " " Is it OK?  It's for remove blank or message line.
    " if getline(1) =~ "^\s*$"
    "   silent exec "norm 2G/^[^\s]\<cr>kd1G"
    " endif
    " if getline('$') == ''
    "   silent exec "norm G?^\s*[^\s]\<cr>2jdG"
    " endif
    " 1
    let l:rpage = substitute(getline(1), '(.*', '', '')
    let l:rsect = substitute(getline(1), '.*(\([^)]*\)).*', '\1', '')
    execute "sil! file ~/vimtmp/" . l:rpage . "_" . l:rsect . ".man"
    setl ft=man nomod
    " setl bufhidden=hide
    setl nobuflisted
    setl ts=8
    setl sw=8
    setl sts=8
    setl nomodifiable
    sil! update!
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
