" vi:set ts=3 sts=3 sw=3 ft=vim et:

let g:debug = []
" echo "debug:\n" . join(g:debug, "\n")

if (v:version < 600)
   echo "version 6 or greater of vim required for lxkcommands."
   finish
endif

let s:commands = { 'git':{}, 'svn':{}, 'hg':{} }
let s:commands['git']['cat'] = 'git show <REV>:<FILE>'
let s:commands['hg']['cat'] = 'hg cat -r <REV> <FILE>'
let s:commands['svn']['cat'] = 'svn cat -r <REV> <FILE>'

let s:versions = { 'git':{}, 'svn':{}, 'hg':{} }
let s:versions['git']['vim:head'] = 'HEAD'
let s:versions['git']['vim:prev'] = 'HEAD~'
let s:versions['svn']['vim:head'] = 'HEAD'
let s:versions['svn']['vim:prev'] = 'PREV'
let s:versions['hg']['vim:head'] = '.'
let s:versions['hg']['vim:prev'] = '.^'

"------------------------------------------------------------------------------
" Diff Mappings: (ALS/SVN/GIT/HG)
"------------------------------------------------------------------------------
" W - (\dw) WITH   Diff current file with some other revision of the same file.
" H - (\dh) HEAD   Will see changes against current HEAD.
" p - (\dp) PREV   Will see changes against previous revision.
"------------------------------------------------------------------------------
map \dw :execute 'sil! call <SID>DiffWithRevision("' . input("Enter other revision: ") . '")'<CR>
map \dh :execute "call <SID>DiffWithRevision(\"vim:head\")"<CR>
map \dp :execute "call <SID>DiffWithRevision(\"vim:prev\")"<CR>
map \dq :execute "call <SID>DiffQuit()"<CR>
let s:diffinfo = ""
nmap <silent> <C-S-Right> :sil! call <SID>DiffNext('next')<CR>
nmap <silent> <C-S-Left> :sil! call <SID>DiffNext('prev')<CR>
nmap <silent> <C-S-Up> :sil! call <SID>DiffNext('curr')<CR>
nmap <silent> <C-S-Down> :sil! call <SID>DiffQuit()<CR>

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
" AdjustPath
"------------------------------------------------------------------------------
" Make some necessary changes to a file path.
"------------------------------------------------------------------------------
function! AdjustPath(path)
   let retval = substitute(a:path, '^\(.\):\\', '/cygdrive/\L\1\E/', '')
   let retval = substitute(retval, '\\', '/', 'g')
   return retval
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
   let shell = &shell
   let shellcmdflag = &shellcmdflag
   let shellxquote = &shellxquote
   set shell=C:/cygwin/bin/bash
   set shellcmdflag=-c
   set shellxquote=\"
   sil! execute "r !" . a:command
   let &shellxquote = shellxquote
   let &shellcmdflag = shellcmdflag
   let &shell = shell
   normal ggdd
   update | close
endfunction

let s:lookorder = [ 'git', 'hg', 'svn' ]
let s:lookfor = { 'git':'.git', 'hg':'.hg', 'svn':'.svn' }
let s:lookmore = { '.svn':1 }

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
   let 
   let path = ""
   while 1
      let g:debug += [ 'while cwd ' . getcwd() ]
      for key in s:lookorder
         let path=s:lookfor[key]
         let g:debug += [ 'path ' . path ]
         if (isdirectory(path))
            let g:debug += [ "found " . path ]
            break
         endif
         let path = ""
      endfor
      let g:debug += [ 'checking ' . path ]
      if ((strlen(path) && !has_key(s:lookmore, path))
         \ || (currdir == $VIMHOME) || (currdir == lastdir))
         let g:debug += [ path . " caused a break" ]
         break
      endif
      if (has_key(s:lookmore, path))
         let topdir = lastdir
      endif
      cd ..
      if (strlen(topdir) && !isdirectory(path))
         execute "cd " . currdir
         break
      endif
      let currdir = getcwd()
   endwhile
   let g:debug += [ 'endwhile cwd ' . getcwd() ]
   let g:debug += [ 'path ' . path ]
   if (isdirectory(path))
      let retval = getcwd()
   else
      let retval = ""
   endif
   execute "cd " . startdir
   let g:debug += [ 'final retval ' . retval ]
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
   for key in s:lookorder
      let g:debug += [ "key " . key ]
      let path=s:lookfor[key]
      let g:debug += [ "path " . path ]
      if (isdirectory(path))
         let retval = key
         let g:debug += [ "breaking..." ]
         break
      endif
   endfor
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
   let lz = &lz
   set lz
   let olddir = <SID>OldPwd()
   let startdir = getcwd()
   let s:diffinfo = 'w:' . a:revname
   execute 'cd ' . <SID>PathTopLevel(expand("%:p"))
   let revtype = <SID>PathRepoType(expand("%:h"))
   if revtype != "unknown"
      let cmd=s:commands[revtype]['cat']
      let cmd=substitute(cmd, '<FILE>', AdjustPath(expand("%")), 'g')
      let revname = a:revname
      if (has_key(s:versions, revtype) && has_key(s:versions[revtype], a:revname))
         let revname = s:versions[revtype][a:revname]
      endif
      let cmd=substitute(cmd, '<REV>', revname, 'g')
      let tmpfile=<SID>PathTmpFile(expand("%:p"))
      call <SID>BuildFileFromSystemCmd(tmpfile, cmd)
      execute "sil! vert diffsplit " . tmpfile
   endif
   execute "cd " . olddir
   execute "cd " . startdir
   let &lz = lz
endfunction

"------------------------------------------------------------------------------
" DiffQuit
"------------------------------------------------------------------------------
" Use s:diffinfo to determine how to best quit a diff window.
"------------------------------------------------------------------------------
function! s:DiffQuit()
   let lz = &lz
   set lz
   if (&diff)
      " clean up if still diffing
      if (!match(s:diffinfo, 'r:'))
         sil! windo bw!
      else
         sil! windo set nodiff fdc=0
         sil! bw
         sil! bd
         sil! e #
      endif
   endif
   let &lz = lz
endfunction

"------------------------------------------------------------------------------
" DiffNext
"------------------------------------------------------------------------------
" Use s:diffinfo to determine last diff method and iterate to next file and
" apply same diff.
"------------------------------------------------------------------------------
function! s:DiffNext(direction)
   let lz = &lz
   set lz
   let end = 0
   call <SID>DiffQuit()
   if (a:direction == "next")
      if (argidx()+1 >= argc())
         echo "Last file"
         let end = 1
      else
         sil! next
      endif
   elseif (a:direction == "prev")
      if (argidx() == 0)
         echo "First file"
         let end = 1
      else
         sil! prev
      endif
   endif
   if (!end)
      if (strlen(strpart(s:diffinfo, 2)) && (strpart(s:diffinfo, 0, 3) != 'f:#'))
         if (!match(s:diffinfo, 'w:'))
            call <SID>DiffWithRevision(strpart(s:diffinfo, 2))
         endif
      else
         echo "No diff history present."
      endif
   endif
   let &lz = lz
endfunction

function! TestIt()
   let g:debug = []
   let revtype = <SID>PathRepoType(expand("%:h"))
   echo "revtype " . revtype
   echo join(g:debug, "\n")
endfunction

