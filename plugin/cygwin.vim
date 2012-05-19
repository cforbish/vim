" vi:set ts=3 sts=3 sw=3 ft=vim et:

if (v:version < 600)
   echo "version 6 or greater of vim required for cygwin commands."
   finish
endif

"------------------------------------------------------------------------------
" Commands:
"------------------------------------------------------------------------------
" Git  - Convert path names befor calling git.
"------------------------------------------------------------------------------
com! -nargs=+ -complete=file Git call Git(<f-args>)
com! -nargs=+ -complete=file Cmd call Cmd(<f-args>)

" "------------------------------------------------------------------------------
" " Cygwpath
" "------------------------------------------------------------------------------
" " Convert a path to a windows path
" "------------------------------------------------------------------------------
" function! Cygwpath(path)
"    let l:retval = system("cygpath -w " . a:path)
"    return l:retval
" endfunction

"------------------------------------------------------------------------------
" Cygwpath
"------------------------------------------------------------------------------
" Convert a path to a windows path
"------------------------------------------------------------------------------
function! Cygwpath(path)
   let l:retval = a:path
   if (match(a:path, '^\') == 0)
      let l:retval = substitute(a:path, '^', 'C:', '')
   else
      let l:retval = substitute(a:path, '^/cygdrive/\(.\)/', '\U\1\E:/', '')
      if (match(a:path, '^\\a:') == 0)
         let l:retval = substitute(a:path, '^', 'C:/cygwin', '')
      endif
   endif
   let l:retval = substitute(l:retval, '/', '\\\\', 'g')
   return l:retval
endfunction

" "------------------------------------------------------------------------------
" " Cygcpath
" "------------------------------------------------------------------------------
" " Convert a path to a linux path
" "------------------------------------------------------------------------------
" function! Cygcpath(path)
"    let l:retval = system("cygpath " . a:path)
"    return l:retval
" endfunction

"------------------------------------------------------------------------------
" Cyglpath
"------------------------------------------------------------------------------
" Convert a path to a linux path
"------------------------------------------------------------------------------
function! Cyglpath(path)
   let l:retval = substitute(a:path, '^\(.\):\\', '/cygdrive/\L\1\E/', '')
   let l:retval = substitute(l:retval, '\\', '/', 'g')
   return l:retval
endfunction

"------------------------------------------------------------------------------
" Git
"------------------------------------------------------------------------------
" Convert paths to linux paths before calling git.
"------------------------------------------------------------------------------
function! Git(...)
   let l:command = "git"
   for l:arg in a:000
      if (match(l:arg, '\') >= 0)
         let l:command = l:command . ' ' . Cyglpath(l:arg)
      else
         let l:command = l:command . ' ' . l:arg
      endif
   endfor
   echo system(l:command)
endfunction

"------------------------------------------------------------------------------
" Cmd
"------------------------------------------------------------------------------
" Convert paths to linux paths before calling command.
"------------------------------------------------------------------------------
function! Cmd(...)
   let l:command = Cyglpath(a:000[0])
   let l:args = a:000[1:]
   for l:arg in l:args
      if (match(l:arg, '\') >= 0)
         let l:command = l:command . ' ' . Cyglpath(l:arg)
      else
         let l:command = l:command . ' ' . l:arg
      endif
   endfor
   echo system(l:command)
endfunction

