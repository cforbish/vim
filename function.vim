" vi:set ts=3 sts=3 sw=3 ft=vim et:

"-------------------------------------------------------------------------------
" Start of reg functions
"-------------------------------------------------------------------------------

function! SelectionToRegs()
   " selection in format of 'a chars for reg a\nb chars for reg b to vim registers
   if match(getline("."), "[a-zA-Z] ") == 0
      let treg = strpart(getline("."), 0, 1)
      let tlen = strlen(treg)
      let ttxt = strpart(getline("."), 2, strlen(getline(".")) - 2)
      let command = "let @" . treg . "=\"" . ttxt . "\""
      execute command
   endif
endfunction

function! CleanRegs()
   " replace contents of regs a-z wi nothing
   let num = char2nr("a")
   while num <= char2nr("z")
      let chr = nr2char(num)
      let command = "let @" . nr2char(num) . "=\"\""
      execute command
      let num = num + 1
   endwhile
endfunction

function! LabelRegs() range
   " prepend a,b,c on a range of lines.
   let num = char2nr("a")
   let lineno = line("'<")
   while lineno <= line("'>")
      execute lineno
      if match(getline("."), '\S') >= 0
         let chr = nr2char(num)
         let tline = chr . " " . getline(".")
         execute 'call setline(".", "' . tline . '")'
         let num = num + 1
      endif
      let lineno = lineno + 1
   endwhile
endfunction

function! RegsToStar()
   " put contents of vim regs a to z to + 'star' clipboard
   let buffer = ""
   let num = char2nr("a")
   while num <= char2nr("z")
      let buffer = buffer . ":register " . nr2char(num) . ":\n"
      let command = 'let buffer = buffer . @' . nr2char(num)
      execute command
      let buffer = buffer . "\n"
      let num = num + 1
   endwhile
   let @+ = buffer
endfunction

function! StarToRegs()
   " set contents of vim regs a to z from + 'star' clipboard
   let fs1 = ":register "
   let fs2 = "[a-z,@]:\n"
   let buffer = ""
   let string = @+ . ":register @:\n"
   let num = 0
   while (strlen(string) && num < 29)
      let offset = match(string, fs1 . fs2)
      let char = strpart(string, offset + strlen(fs1), 1)
      if (char == "@")
         break
      endif
      let string = strpart(string, (offset + strlen(fs1) + 3))
      let offset = match(string, fs1 . fs2)
      let pattern = strpart(string, 0, offset - 1)
      if (strlen(pattern))
         let command = 'let @' . char . ' = pattern'
         execute command
      endif
      let num = num + 1
   endwhile
endfunction

function! RegFile(regfile)
   " use entire file for SelectionToRegs call.
   set lz
   execute "e " . a:regfile
   normal ggVG_+
   execute 'call SelectionToRegs()'
   bw
   set nolz
endfunction

"-------------------------------------------------------------------------------
" End of reg functions
"-------------------------------------------------------------------------------

function! CharInc()
   " Increment current character by one.
   let idx = col('.') - 1
   let num = char2nr(getline('.')[idx]) + 1
   let chr = nr2char(num)
   let parta = strpart(getline('.'), 0, idx)
   let partb = strpart(getline('.'), idx + 1)
   call setline(line('.'), parta . chr . partb)
endfunction

function! CharDec()
   " Increment current character by one.
   let idx = col('.') - 1
   let num = char2nr(getline('.')[idx]) - 1
   let chr = nr2char(num)
   let parta = strpart(getline('.'), 0, idx)
   let partb = strpart(getline('.'), idx + 1)
   call setline(line('.'), parta . chr . partb)
endfunction

function! Replace(spattern, rpattern) range
" Replace words keeping two case styles the same
" For example:
" Replace("black", "cyan")
" will replace Black with Cyan, BLACK with CYAN and black with cyan.
" Command: :Replace black cyan
   set lz
   let rupper = toupper(a:rpattern)
   let rlower = tolower(a:rpattern)
   let rfirst = substitute(rlower, '^\(.\)', '\u\1', "")
   let @/ = toupper(a:spattern)
   sil! '<,'>s##\=rupper#gI
   let slower = tolower(a:spattern)
   let @/ = substitute(slower, '^\(.\)', '\u\1', "")
   sil! '<,'>s##\=rfirst#gI
   let @/ = slower
   sil! '<,'>s##\=rlower#gI
   set nolz
endfunction

function! DumpExpand()
   echo "<cword>  " . expand("<cword>")
   echo "<cWORD>  " . expand("<cWORD>")
   echo "<cfile>  " . expand("<cfile>")
   echo "<afile>  " . expand("<afile>")
   echo "<abuf>   " . expand("<abuf>")
   echo "<amatch> " . expand("<amatch>")
   echo "<sfile>  " . expand("<sfile>")
   echo "%     " . expand("%")
   echo "%:p   " . expand("%:p")
   echo "%:p:h " . expand("%:p:h")
   echo "%:h   " . expand("%:h")
   echo "%:t   " . expand("%:t")
   echo "%:r   " . expand("%:r")
   echo "%:e   " . expand("%:e")
endfunction

function! BackSlashRegionSet() range
   let largest = 0
   '<s/[\s\\]*$/\\/
   '<,'>s/\s*\\\s*$//
   let lineno = line("'<")
   while lineno <= line("'>")
      execute lineno
      if (virtcol("$") > largest)
         let largest = virtcol("$")
      endif
      let lineno = lineno + 1
   endwhile
   let lineno = line("'<")
   while lineno <= line("'>")
      execute lineno
      let diffcount = largest - virtcol("$") + 2
      execute "normal " . diffcount . "A "
      execute "normal A\\"
      let lineno = lineno + 1
   endwhile
   execute line("'<")
endfunction

function! BackSlashRegionClear() range
   '<,'>s/[\s\\]*$//
endfunction

function! EditPath(title)
   let string = g:editpath . ","
   let command = ""
   while ((stridx(string, ",") >= 0) && !strlen(command))
      let idx = stridx(string, ",")
      while (idx == 0)
         let string = strpart(string, 1)
         let idx = stridx(string, ",")
         let part = strpart(string, 0, idx)
      endwhile
      let string = strpart(string, idx)
      if (strlen(part))
         let dir = substitute(part, "/$", "", "") . "/"
         if (filereadable(dir . a:title))
            " echo "found file " dir . a:title
            let command = "edit " . dir . a:title
         endif
      endif
   endwhile
   if (strlen(command))
      execute command
   endif
endfunction

function! So(sofile) range
   set lz
   let regvalue = @*
   normal y
   new
   normal "*p
   let command="sil! so " . a:sofile
   execute command
   2
   normal yG
   q!
   normal V'>x"0P
   let @* = regvalue
   set nolz
endfunction

function! Date()
   return strftime("%m-%d-%y")
endfunction

function! SwapRemove()
   " remove swap file for current file
   set lz
   if (strlen(expand("%:h")))
      let dir = expand("%:h")
   else
      let dir = '.'
   endif
   exec "!rm " . dir . '/.' . expand("%:t") . '.swp'
   set nolz
endfunction

function! BwPattern(pattern)
set lz
let oldp = @p
redir @p
sil! ls
redir END
new
normal "pp
let command = "v#" . a:pattern . "#d"
sil! execute command
sil! g#^[^"]*"#s###g
sil! g#".*#s###g
%j
normal ^"py$
if (strlen(@p))
         sil! execute "bw! " . @p
else
         echo "no buffers to remove."
endif
bw!
let @p = oldp
set nolz
endfunction

function! BwTmp()
call BwPattern("\\/vimtmp\\/")
endfunction

"-------------------------------------------------------------------------------
" BwDups
"-------------------------------------------------------------------------------
" Remove and unload one occurrence of buffers that are loaded twice.
"-------------------------------------------------------------------------------
function! BwDups()
   if (v:version < 700)
      echohl ErrorMsg
      " Version 7 or better needed for use of dictionary variable type.
      echo "Must have vim version 7 or greater for BwDups."
      echohl None
      return
   endif
   let l:lz = &lz
   set lz
   let oldp = @p
   redir @p
   sil! ls
   redir END
   new
   normal "pPggdd
   let l:filehash = { '[No Name]': 0 }
   let l:lineno = 1
   while (l:lineno <= line('$'))
      let l:bufnumb = substitute(getline(l:lineno), '^\s*\(\d*\).*', '\1', '')
      let l:bufname = substitute(getline(l:lineno), '^.*"\(.*\)".*', '\1', '')
      if (has_key(l:filehash, l:bufname))
         exec "bw! " . l:bufnumb
      else
         let l:filehash[l:bufname] = l:bufnumb
      endif
      let l:lineno += 1
   endwhile
   let @p = oldp
   sil! bw!
   if (!l:lz)
      set nolz
   endif
endfunction

function! ClassArg(classname)
   set lz
   r ~/vim_scripts/templates/classarg.cpp
   normal V/^" <AUTO_VIM_SCRIPT_TAG \d
   sil! '<,'>s/\<classname\>/\=a:classname/g
   normal '>dd'<dd
   set nolz
endfunction

"-------------------------------------------------------------------------------
" SearchBuild
"-------------------------------------------------------------------------------
" Build a search pattern from a file with a pattern per line.
"-------------------------------------------------------------------------------
function! SearchBuild(asword)
   if (a:firstline == a:lastline)
      " since only one line seliected (or no selection)
      " use entire file as a list of search patterns
      sil! g;^\s*$;d
      if (a:asword)
         sil! g;.*;s;;\\<&\\>;g
      else
         sil! g;.*;s;;&;g
      endif
      sil! %j
   else
      if (a:asword)
         sil! '<,'>g;^\S.*;s;;\\<&\\>;g
      else
         sil! '<,'>g;^\S.*;s;;&;g
      endif
      sil! '<,'>j
      sil! s;\s*$;;g
   endif
   sil! s; ;\\|;g
   sil! let @/=getline('.')
   sil! undo
endfunction

"-------------------------------------------------------------------------------
" IncludeExpr
"-------------------------------------------------------------------------------
" Handle includeexpr for completing filepaths to cygwin paths.
"-------------------------------------------------------------------------------
function! IncludeExpr(filename)
   if (isdirectory("\\cygwin\\"))
      let l:retval = substitute(a:filename, '^/', '\\cygwin\\', 'g')
      let l:retval = substitute(l:retval, '/', '\\', 'g')
      if (!filereadable(l:retval))
         let l:retval = a:filename
      endif
   else
      let l:retval = a:filename
   endif
   return(l:retval)
endfunction

"-------------------------------------------------------------------------------
" GrepList
"-------------------------------------------------------------------------------
" Generate a list of files using command a:command and grep the current search
" pattern in these files.  If files match put the file in args() so :n and :N go
" between the files.
"-------------------------------------------------------------------------------
function! GrepList(command)
   let l:lz = &lz
   set lz
   set hls
   let l:list = substitute(system(a:command . ' | xargs grep -l "' . @/ . '"'), '\n', ' ', 'g')
   if (strlen(l:list))
      exec 'n ' . l:list
   else
      echo "No files found that match."
   endif
   let &lz = l:lz
endfunction

"-------------------------------------------------------------------------------
" GrepIter
"-------------------------------------------------------------------------------
" Like GrepList, but start issue vims internal grepprg feature for iterating to
" all the matches.
"-------------------------------------------------------------------------------
function! GrepIter(command)
   let l:lz = &lz
   set lz
   set hls
   exec 'sil! grep "' . @/ . '" ' . substitute(system(a:command), '\n', ' ', 'g')
   let &lz = l:lz
endfunction

