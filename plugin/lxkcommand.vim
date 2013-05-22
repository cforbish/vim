" vi:set ts=3 sts=3 sw=3 ft=vim et:

let g:debug = []
" echo "debug:\n" . join(g:debug, "\n")

if (v:version < 600)
   echo "version 6 or greater of vim required for lxkcommands."
   finish
endif

"------------------------------------------------------------------------------
" Diff Mappings: (ALS/SVN/GIT/HG)
"------------------------------------------------------------------------------
" W - (\dw) WITH   Diff current file with some other revision of the same file.
" B - (\db) BASE   Diff just like git diff or svn diff.
" H - (\dh) HEAD   Will see changes against current HEAD.
" p - (\dp) PREV   Will see changes against previous revision.
" O - (\do) ORIG   Does a diff with current file and a .orig.
" F - (\df) FILE   Prompts for a file to diff current file against.
" # - (\d#) LAST   Does a diff with current file and last file.
" Q - (\dq) QUIT   Closes diff session and window to the right.
"------------------------------------------------------------------------------
map \dw :execute 'sil! call <SID>DiffWithRevision("' . input("Enter other revision: ") . '", "w:")'<CR>
map \db :execute "call <SID>DiffWithRevision(\"vim:base\", 'w:')"<CR>
map \dh :execute "call <SID>DiffWithRevision(\"vim:head\", 'w:')"<CR>
map \dp :execute "call <SID>DiffWithRevision(\"vim:prev\", 'w:')"<CR>
map \dr :execute 'sil! call <SID>DiffWithRevision("' . input("Enter revision to diff: ") . '", "r:")'<CR>
map \dq :execute "call <SID>DiffQuit()"<CR>
map \do :call <SID>DiffWithFile('%.orig')<CR>
map \df :call <SID>DiffWithFile(input('Enter filename: ', '', 'file'))<CR>
map \d# :call <SID>DiffWithFile('#')<CR>
nmap <silent> <C-S-Right> :sil! call <SID>DiffNext('next')<CR>
nmap <silent> <C-S-Left> :sil! call <SID>DiffNext('prev')<CR>
nmap <silent> <C-S-Up> :sil! call <SID>DiffNext('curr')<CR>
nmap <silent> <C-S-Down> :sil! call <SID>DiffQuit()<CR>

"------------------------------------------------------------------------------
" File Mappings:
"------------------------------------------------------------------------------
" \fb - does a blame for current file in separate window.
"------------------------------------------------------------------------------
map \fb :call <SID>FileBlame()<CR>

"------------------------------------------------------------------------------
" Commands:
"------------------------------------------------------------------------------
com! -nargs=1 -complete=shellcmd DiffWithRevision call <SID>DiffWithRevision(<q-args>, 'w:')
com! -nargs=+ -complete=file Cmd call <SID>Cmd(<f-args>)
com! -nargs=+ -complete=file Git call <SID>Cmd("git", <f-args>)
com! -nargs=+ -complete=file Hg call <SID>Cmd("hg", <f-args>)
com! -nargs=+ -complete=file Svn call <SID>Cmd("svn", <f-args>)
com! -nargs=+ -complete=file VF call <SID>VF(<f-args>)
com! -range -nargs=0 GitAmmend call <SID>GitAmmend()
com! -range -nargs=0 GitBlame call <SID>GitBlame()
com! -range -nargs=0 Vstatus call <SID>Vstatus()
com! -range -nargs=0 Vrevert call <SID>Vrevert()

let s:diffinfo = ""
let s:diffwidth = 0

let s:commands = { 'git':{}, 'svn':{}, 'hg':{} }
let s:commands['git']['cat'] = 'git show <REV>:<FILE>'
let s:commands['hg']['cat'] = 'hg cat -r <REV> <FILE>'
let s:commands['svn']['cat'] = 'svn cat -r <REV> <FILE>'
let s:commands['git']['blame'] = 'git blame <FILE>'
let s:commands['hg']['blame'] = 'hg blame <FILE>'
let s:commands['svn']['blame'] = 'svn blame <FILE>'
let s:commands['git']['status'] = 'git status'
let s:commands['hg']['status'] = 'hg status'
let s:commands['svn']['status'] = 'svn status'
let s:commands['git']['revert'] = 'git checkout HEAD <FILE>'
let s:commands['hg']['revert'] = 'hg revert <FILE>'
let s:commands['svn']['revert'] = 'svn revert <FILE>'

let s:lookorder = [ 'git', 'hg', 'svn' ]
let s:lookfor = { 'git':'.git', 'hg':'.hg', 'svn':'.svn' }
let s:lookmore = { '.svn':1 }

let s:versions = { 'git':{}, 'svn':{}, 'hg':{} }
let s:versions['git']['vim:base'] = ''
let s:versions['git']['vim:head'] = 'HEAD'
let s:versions['git']['vim:prev'] = 'HEAD~'
let s:versions['svn']['vim:base'] = 'COMMITTED'
let s:versions['svn']['vim:head'] = 'COMMITTED'
let s:versions['svn']['vim:prev'] = 'PREV'
let s:versions['hg']['vim:base'] = '.'
let s:versions['hg']['vim:head'] = '.'
let s:versions['hg']['vim:prev'] = '.^'

let s:previous = { 'git':{'printf':'%s~'}, 'svn':{'eval':'%s-1'}, 'hg':{'printf':'%s^'} }

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
" BuildCmd
"------------------------------------------------------------------------------
" Build a command with file paths adjusted for cygwin potentially running.
"------------------------------------------------------------------------------
function! s:BuildCmd(...)
   if (type(a:000[0]) == 3)
      let args = a:000[0]
   else
      let args = a:000
   endif
   let rc = AdjustPath(args[0])
   let args = args[1:]
   for arg in args
      if (match(arg, '\') >= 0)
         let rc = rc . ' ' . AdjustPath(arg)
      elseif (match(arg, '%') >= 0)
         let rc = rc . ' ' . substitute(arg, '%', AdjustPath(expand("%")), 'g')
      else
         let rc = rc . ' ' . arg
      endif
   endfor
   return rc
endfunction

"------------------------------------------------------------------------------
" Cmd
"------------------------------------------------------------------------------
" Convert paths to linux paths before calling command.
"------------------------------------------------------------------------------
function! s:Cmd(...)
   let command=<SID>BuildCmd(a:000)
   echo system(command)
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
   if (match(getcwd(), '/'))
      let shell = &shell
      let shellcmdflag = &shellcmdflag
      let shellxquote = &shellxquote
      set shell=C:/cygwin/bin/bash
      set shellcmdflag=-c
      set shellxquote=\"
   endif
   sil! execute "r !" . a:command
   if (match(getcwd(), '/'))
      let &shellxquote = shellxquote
      let &shellcmdflag = shellcmdflag
      let &shell = shell
   endif
   normal ggdd
   update | close
endfunction

function! s:VF(...)
   echo "VF number args " . a:0
   echo "VF number max " . len(a:000)
   let tmpfile=<SID>PathTmpFile(getcwd() . '_' . join(a:000, "_"))
   let command=join(a:000, " ")
   echo "VF number file " . tmpfile
   call <SID>BuildFileFromSystemCmd(tmpfile, command)
   execute 'e ' . tmpfile
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
      if (isdirectory(a:1))
         let pathname = a:1
      else
         let pathname = substitute(a:1, '^\(.*\)\' . s:os_slash . '.*', '\1', "g")
      endif
   else
      let pathname = getcwd()
   endif
   if (strlen(pathname) && isdirectory(pathname))
      execute "cd " . pathname
   endif
   let topdir = ""
   let lastdir = ""
   let currdir = getcwd()
   let path = ""
   while 1
      for key in s:lookorder
         let path=s:lookfor[key]
         if (isdirectory(path))
            break
         endif
         let path = ""
      endfor
      if ((strlen(path) && !has_key(s:lookmore, path))
         \ || (currdir == $VIMHOME) || (currdir == lastdir))
         break
      endif
      let lastdir = getcwd()
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
   if (isdirectory(path))
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
   let retval = "unknown"
   if a:0 > 0
      let filename = a:1
   else
      let filename = expand("%:p")
   endif
   let tl = <SID>PathTopLevel(filename)
   if (strlen(tl))
      execute 'cd ' . tl
      for key in s:lookorder
         let path=s:lookfor[key]
         if (isdirectory(path))
            let retval = key
            break
         endif
      endfor
   endif
   execute "cd " . startdir
   return retval
endfunction

"------------------------------------------------------------------------------
" Get OLDPWD
"------------------------------------------------------------------------------
function! s:OldPwd()
   let startdir = getcwd()
   try
      sil! cd -
   endtry
   let retval = getcwd()
   execute "cd " . startdir
   return retval
endfunction

"------------------------------------------------------------------------------
" GetPrevious
"------------------------------------------------------------------------------
" Find a revision before a revision (tricky because of sha1)
"------------------------------------------------------------------------------
function! s:GetPrevious(type, rev)
    if (has_key(s:previous, a:type))
        let info=s:previous[a:type]
        if (has_key(info, 'eval'))
            return eval(printf(info['eval'], a:rev))
        elseif (has_key(info, 'printf'))
            return printf(info['printf'], a:rev)
        fi
    endif
endfunction

"------------------------------------------------------------------------------
" DiffWithRevision
"------------------------------------------------------------------------------
" Get a difference between current file and some version of same
" file as a:revname using version control system mof current file.
"------------------------------------------------------------------------------
function! s:DiffWithRevision(revname, type)
   let lz = &lz
   set lz
   let olddir = <SID>OldPwd()
   let startdir = getcwd()
   let s:diffinfo = a:type . a:revname
   let tl = <SID>PathTopLevel(expand("%:p"))
   let prefix = ''
   if a:type == 'r:'
      let prefix = 'aft_'
   endif
   if (strlen(tl))
      execute 'cd ' . tl
      let revtype = <SID>PathRepoType(expand("%:h"))
      if revtype != "unknown"
         let s:diffwidth=winwidth(0)
         if (match(a:revname, '!'))
            let fmt=s:commands[revtype]['cat']
            let fmt=substitute(fmt, '<FILE>', AdjustPath(expand("%")), 'g')
            let revname = a:revname
            if (has_key(s:versions, revtype) && has_key(s:versions[revtype], a:revname))
               let revname = s:versions[revtype][a:revname]
            endif
            let cmd=substitute(fmt, '<REV>', revname, 'g')
         else
            let cmd=<SID>BuildCmd(split(strpart(a:revname, 1)))
         endif
         let tmpfile=<SID>PathTmpFile(prefix . expand("%:p"))
         call <SID>BuildFileFromSystemCmd(tmpfile, cmd)
         if a:type == 'r:'
            let prefix='bef_'
            let revname=<SID>GetPrevious(revtype, revname)
            let cmd=substitute(fmt, '<REV>', revname, 'g')
            let curfile=<SID>PathTmpFile(prefix . expand("%:p"))
            call <SID>BuildFileFromSystemCmd(curfile, cmd)
            exec 'edit ' . curfile
         endif
         execute "sil! vert diffsplit " . tmpfile
      endif
   else
      echo "Could not determine toplevel directory."
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
      " Attempt to restore old window width
      if s:diffwidth > 0
         exec 'set columns=' . s:diffwidth
         let s:diffwidth = 0
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
            call <SID>DiffWithRevision(strpart(s:diffinfo, 2), 'w:')
         elseif (!match(s:diffinfo, 'r:'))
            call <SID>DiffWithRevision(strpart(s:diffinfo, 2), 'r:')
         elseif (!match(s:diffinfo, 'f:'))
            call DiffWithFile(strpart(s:diffinfo, 2))
         endif
      else
         echo "No diff history present."
      endif
   endif
   let &lz = lz
endfunction

"------------------------------------------------------------------------------
" GitAmmend
"------------------------------------------------------------------------------
" Ammend to head
" If not in temporary file, build temporary file with log message from head.
" While in the temporary file the command will commit the modified message.
"------------------------------------------------------------------------------
function! s:GitAmmend()
   let lz = &lz
   set lz
   let tl = ''
   if (&mod)
      echo "Current buffer has modifications."
   else
      if (isdirectory(".git"))
         let tl = getcwd()
      else
         if (<SID>PathRepoType(expand("%:p")) == "git")
            let tl = <SID>PathTopLevel(expand("%:p"))
         else
            let tl = <SID>PathTopLevel(getcwd())
         endif
      endif
      if (strlen(tl))
         execute "cd " . tl
         let tmpfilename = <SID>PathTmpFile(getcwd()) . "_git_ammend"
         if (stridx(expand("%:p"), expand(tmpfilename)))
            execute "edit " . tmpfilename
            %d
            sil! r !git whatchanged HEAD~1..HEAD
            sil! v;^    ;d
            sil! %s;^    ;;g
            sil! update
         else
            execute "Git commit --amend -F " . expand("%:p")
            execute "bw!"
         endif
      else
         echo "Could not determine a top level for current file or current directory"
      endif
   endif
   let &lz = lz
endfunction

"------------------------------------------------------------------------------
" GitBlame
"------------------------------------------------------------------------------
" See revision and user of current line
"------------------------------------------------------------------------------
function! s:GitBlame()
   exec 'Git blame -L ' . line('.') . ',' . line('.') . ' ' . expand("%")
endfunction

"------------------------------------------------------------------------------
" FileBlame
"------------------------------------------------------------------------------
" Bring up blame window for either git or svn.
"------------------------------------------------------------------------------
function! s:FileBlame() range
   let revtype = <SID>PathRepoType()
   if (revtype != 'unknown' && has_key(s:commands, revtype)
      \ && has_key(s:commands[revtype], 'blame'))
      let lz = &lz
      set lz
      let tempfile = <SID>PathTmpFile(expand("%:p")) . ".blame"
      let startdir = getcwd()
      execute "sil! cd " . expand("%:p:h")
      let lineno = line(".")
      let cmd=s:commands[revtype]['blame']
      let cmd=substitute(cmd, '<FILE>', AdjustPath(expand("%")), 'g')
      execute "new " . tempfile
      sil! %d
      execute 'sil! r !' . cmd
      1d
      update
      execute lineno
      execute "sil! cd " . startdir
      let &lz = lz
   else
      echo "Sorry, ALS has no concept of blame."
   endif
endfunction

function! s:Vstatus()
   if (&mod)
      echo "Current buffer has modifications."
   else
      let revtype = <SID>PathRepoType(getcwd())
      if (revtype != 'unknown' && has_key(s:commands, revtype)
         \ && has_key(s:commands[revtype], 'status'))
         let lz = &lz
         set lz
         let tempfile = <SID>PathTmpFile(getcwd()) . ".status"
         execute "edit " . tempfile
         sil! %d
         let cmd=s:commands[revtype]['status']
         execute 'sil! r !' . cmd
         update
         let &lz = lz
      endif
   endif
endfunction

function! s:Vrevert()
   let revtype = <SID>PathRepoType(expand("%:p"))
   if (revtype == 'unknown')
      echo 'Could not determine repository type of current file.'
   else
      if (has_key(s:commands, revtype) && has_key(s:commands[revtype], 'revert'))
         let resp = input("Wipe out local changes to current file (yes/no): ")
         let resp = tr(resp, 'NOYES', 'noyes')
         if (match(resp, '\c^y') >= 0)
            let lz = &lz
            set lz
            let cmd=s:commands[revtype]['revert']
            let cmd=substitute(cmd, '<FILE>', AdjustPath(expand("%")), 'g')
            echo system(cmd)
            let &lz = lz
         endif
      else
         echo 'This should not happen, if it does modify.'
      endif
   endif
endfunction

"------------------------------------------------------------------------------
" DiffWithFile
"------------------------------------------------------------------------------
" Diff with another file (a:filename is the other file).
"------------------------------------------------------------------------------
function! s:DiffWithFile(filename)
   let lz = &lz
   set lz
   let s:diffwidth=columns()
   let s:diffinfo = 'f:' . a:filename
   normal gg0
   execute "sil! vert diffsplit " . AdjustPath(a:filename)
   normal hgglgg
   sil! redraw!
   let &lz = lz
endfunction

function! TestIt()
   let g:debug = []
   echo join(g:debug, "\n")
endfunction

