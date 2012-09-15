" vi:set ts=3 sts=3 sw=3 ft=vim et:

if (v:version < 600)
   echo "version 6 or greater of vim required for lxkcommands."
   finish
endif

"------------------------------------------------------------------------------
" Setup variable to represent slash to use for path names for current OS.
"------------------------------------------------------------------------------
if (match(getcwd(), '/'))
   let s:os_slash="\\"
else
   let s:os_slash="/"
endif

"------------------------------------------------------------------------------
" CanDo
"------------------------------------------------------------------------------
" Simply determine if the command passed in as a:cmd can be run on the current
" system in the current environment.
"------------------------------------------------------------------------------
function! s:CanDo(cmd)
   let result = system(a:cmd)
   return !v:shell_error
endfunction

"------------------------------------------------------------------------------
" AdjustPath
"------------------------------------------------------------------------------
" Make some necessary changes to a file path.
"------------------------------------------------------------------------------
function! AdjustPath(filename)
   let retval = system("cygpath " . a:filename)
   if (v:shell_error)
      let retval = a:filename
   else
      let retval = substitute(retval, '\n', '', '')
   endif
   return retval
endfunction

"------------------------------------------------------------------------------
" PathTopLevel
"------------------------------------------------------------------------------
" try to determine top level path by searching back for either .toplevel or
" .git .hg .svn  at directory of a:1 as full path to file.
"------------------------------------------------------------------------------
function! s:PathTopLevel(...)
   let startdir = getcwd()
   if a:0 > 0
      let pathname = a:1
   else
      let pathname = substitute(a:1, '^\(.*\)\' . s:os_slash . '.*', '\1', "g")
   endif
   if (strlen(pathname) && isdirectory(pathname))
      execute "cd " . pathname
   endif
   let topdir = ""
   let lastdir = ""
   let currdir = getcwd()
   while (!filereadable(".toplevel") && !isdirectory(".git")  && !isdirectory(".hg")
      \ && (currdir != $VIMHOME) && (currdir != lastdir))
      let lastdir = getcwd()
      if (isdirectory(".svn"))
         let topdir = lastdir
      endif
      cd ..
      if (strlen(topdir) && !isdirectory(".svn"))
         execute "cd " . currdir
         break
      endif
      let currdir = getcwd()
   endwhile
   if (filereadable(".toplevel") || isdirectory(".git") || isdirectory(".hg")
      \ || isdirectory(".svn"))
      let retval = getcwd()
   else
      let retval = ""
   endif
   execute "cd " . startdir
   return retval
endfunction

"------------------------------------------------------------------------------
" PathRepoType
"------------------------------------------------------------------------------
" Get post als revision type for filename with is a full path to a file.
"------------------------------------------------------------------------------
function! s:PathRepoType(...)
   let startdir = getcwd()
    if a:0 > 0
        let filename = a:1
    else
        let filename = expand("%:p")
    endif
   let dir = substitute(filename, '^\(.*\)\' . s:os_slash . '.*', '\1', "g")
   let file = substitute(filename, '^.*\' . s:os_slash . '\(.*\)', '\1', "g")
   if (strlen(dir))
      execute "cd " . dir
   endif
   let retval = "unknown"
   if (<SID>CanDo("git --version"))
      " try git first as it is faster of the three.
      let result = system("git ls-files --stage " . file . " | head -1")
      if (strlen(result) && match(result, '^fatal:\|^error:'))
         let retval = "git"
      endif
   endif
   if ((retval == "unknown") && <SID>CanDo("hg version"))
      " try git first as it is faster of the three.
      let result = system("hg status " . file . " | head -1")
      if (match(result, '^abort:\|^?'))
         let retval = "hg"
      endif
   endif
   if ((retval == "unknown") && <SID>CanDo("svn --version"))
      " try svn next as it is faster than als.
      let adjpath = AdjustPath(filename)
      let result = system("svn info " . adjpath . " | head -1")
      if (strlen(result) && match(result, 'Not a versioned resource\|is not a working copy') < 0)
         let retval = "svn"
      endif
   execute "cd " . startdir
   return retval
endfunction

