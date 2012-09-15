" vi:set ts=3 sts=3 sw=3 ft=vim et:

let g:debug = []
" echo "debug:\n" . join(g:debug, "\n")

if (v:version < 600)
   echo "version 6 or greater of vim required for lxkcommands."
   finish
endif

let s:command = { 'git':{}, 'svn':{}, 'hg':{} }
let s:command['git']['cat'] = 'git show <REV>:<FILE>'
let s:command['hg']['cat'] = 'hg cat -r <REV> <FILE>'
let s:command['svn']['cat'] = 'svn cat -r <REV> <FILE>'

"------------------------------------------------------------------------------
" Diff Mappings: (ALS/SVN/GIT/HG)
"------------------------------------------------------------------------------
" W - (\dw) WITH   Diff current file with some other revision of the same file.
"------------------------------------------------------------------------------
map \dw :execute 'call <SID>DiffWithRevision("' . input("Enter other revision: ") . '")'

"------------------------------------------------------------------------------
" Commands:
"------------------------------------------------------------------------------
com! -nargs=1 -complete=shellcmd DiffWithRevision call <SID>DiffWithRevision(<q-args>)

"------------------------------------------------------------------------------
" Setup variable to represent slash to use for path names for current OS.
"------------------------------------------------------------------------------
if (match(getcwd(), '/'))
   let s:os_slash="\\"
else
   let s:os_slash="/"
endif

"------------------------------------------------------------------------------
" Determine a good directory to place temporary files.
"------------------------------------------------------------------------------
if (!strlen($VIMTMPDIR))
   if (strlen($VIMHOME))
      if (isdirectory($VIMHOME . s:os_slash . "vimtmp"))
         let $VIMTMPDIR = $VIMHOME . s:os_slash . "vimtmp"
      endif
   elseif (strlen($HOME))
      if (isdirectory($HOME . s:os_slash . "vimtmp"))
         let $VIMTMPDIR = $HOME . s:os_slash . "vimtmp"
      endif
      let $VIMHOME=$HOME
   endif
   if (!strlen($VIMTMPDIR))
      set shellslash
      let $VIMTMPDIR = substitute(tempname(), '\(.*\)/.*', '\1', '')
      set noshellslash
   endif
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
" PathTmpFile
"------------------------------------------------------------------------------
" Build a VIMTMPDIR version of file passed in as full path as a:filename
"------------------------------------------------------------------------------
function! s:PathTmpFile(filename)
   if (s:os_slash == "\\")
      let retval = substitute(a:filename, '^\(\a\):', '_\1_', "g")
   else
      let retval = a:filename
   endif
   let retval = $VIMTMPDIR . s:os_slash . substitute(retval, s:os_slash, '_', "g")
   return retval
endfunction

"------------------------------------------------------------------------------
" BuildFileFromSystemCmd
"------------------------------------------------------------------------------
" This function exists because on cygwin system does not honor a '>' character
" to redirect to a file.
"------------------------------------------------------------------------------
function! s:BuildFileFromSystemCmd(file, command)
   execute "new " . a:file
   %d
   execute "r !" . a:command
   normal ggdd
   update | close
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
      let pathname = substitute(a:1, '^\(.*\)\' . s:os_slash . '.*', '\1', "g")
   else
      let pathname = getcwd()
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
   execute 'cd ' . <SID>PathTopLevel(expand("%:p"))
   let retval = "unknown"
   if (isdirectory(".git") && <SID>CanDo("git --version"))
      " try git first as it is faster of the three.
      let result = system("git ls-files --stage " . expand("%:t") . " | head -1")
      if (strlen(result) && match(result, '^fatal:\|^error:'))
         let retval = "git"
      endif
   endif
   if ((retval == "unknown") && isdirectory(".hg") && <SID>CanDo("hg version"))
      " try git first as it is faster of the three.
      let result = system("hg status " . expand("%:t") . " | head -1")
      if (!v:shell_error && match(result, '^abort:\|^?'))
         let retval = "hg"
      endif
   endif
   if ((retval == "unknown") && isdirectory(".svn") && <SID>CanDo("svn --version"))
      " try svn next as it is faster than als.
      let result = system("svn info " . expand("%:t") . " | head -1")
      if (strlen(result) && match(result, 'Not a versioned resource\|is not a working copy') < 0)
         let retval = "svn"
      endif
   endif
   execute "cd " . startdir
   return retval
endfunction

"------------------------------------------------------------------------------
" Get OLDPWD
"------------------------------------------------------------------------------
function! s:OldPwd()
   let startdir = getcwd()
   cd -
   let retval = getcwd()
   execute "cd " . startdir
   return retval
endfunction

"------------------------------------------------------------------------------
" DiffWithRevision
"------------------------------------------------------------------------------
" Get a difference between current file and some version of same
" file as a:revname using version control system mof current file.
"------------------------------------------------------------------------------
function! s:DiffWithRevision(revname)
   let olddir = <SID>OldPwd()
   let startdir = getcwd()
   execute 'cd ' . <SID>PathTopLevel(expand("%:p"))
   let revtype = <SID>PathRepoType(expand("%:h"))
   if revtype != "unknown"
      let cmd=s:command[revtype]['cat']
      let cmd=substitute(cmd, '<FILE>', expand("%:t"), 'g')
      let cmd=substitute(cmd, '<REV>', a:revname, 'g')
      let tmpfile=<SID>PathTmpFile(expand("%:p"))
      call <SID>BuildFileFromSystemCmd(tmpfile, cmd)
      execute "sil! vert diffsplit " . tmpfile
   endif
   execute "cd " . olddir
   execute "cd " . startdir
endfunction

