" vi:set ts=3 sts=3 sw=3 ft=vim et:

if (v:version < 600)
   echo "version 6 or greater of vim required for lxkcommands."
   finish
endif

"------------------------------------------------------------------------------
" Diff Mappings: (ALS/MLS/GIT)
"------------------------------------------------------------------------------
" B - (\db) BASE   Diff just like git diff or svn diff.
" H - (\dh) HEAD   Will see changes made to a file after git add.
" M - (\dm) MASTER trunk/master pride-next/master ...
" D - (\dd) DAILY  trunk/daily pride-next/daily ...
" G - (\dg) BDAILY trunk/lastgood (not all branches have this).
" T - (\dt) TOP    Diffs against remote revision workspace originated from.
" C - (\dc) CORE   Gets latest file from svn and does a diff.
" O - (\do) ORIG   Does a diff with current file and a .orig (ALS)
" L - (\dl) LINE   Does a diff of a revision in which current line changed.
" F - (\df) FILE   Prompts for a file to diff current file against.
" F - (\du) URL    Prompts for a svn path to diff against.
" R - (\dr) REV    Diff changes of one revieion (works with Versions function).
" W - (\dw) WITH   Diff current file with some other revision of the same file.
" # - (\d#) LAST   Does a diff with current file and last file.
" S - (\dS) SNAP   Does a diff with current file and file from yesterday.
" Q - (\dq) QUIT   Closes diff session and window to the right.
" X - (\dx) KILL   Closes diff session and any vimtmpdir windows.
"
"                                    *-*-*-H
"                                   /
"                                 *-*-*
" local git repo                 /      
" (pride-next)       -G-*-*-D-*-T-*-*-*-M
"                                      /
"                                     /<------- git mls fetch -a
"                                    /
" subversion     -G-*-*-D-*-*-*-*-*-*-*-*-*-C
" (lf/pride/next/wip)
" (https://mls:8043/mls3/lf/pride/next/wip)
"
"------------------------------------------------------------------------------
map \db :execute "call DiffWithRevision(\"vim:base\")"
map \dh :execute "call DiffWithRevision(\"vim:head\")"
map \dm :execute "call DiffWithRevision(\"vim:master\")"
map \dd :execute "call DiffWithRevision(\"vim:daily\")"
map \dg :execute "call DiffWithRevision(\"vim:bdaily\")"
map \dt :execute "call DiffWithRevision(\"vim:tlver\")"
map \dc :execute "call DiffWithRevision(\"vim:core\")"
map \do :sil! vert diffsplit %.orig
map \dl :execute "call DiffLineRev()"
map \df :sil! vert diffsplit 
map \du :execute 'call DiffWithSVNUrl("' . input("Enter svn path: ") . '")'
map \dr :execute "call DiffVersion()"
map \dw :execute 'call DiffWithRevision("' . input("Enter other revision: ") . '")'
map \d# :sil! vert diffsplit #:windo normal gg
map \ds :execute "call DiffSnapshot()"
" map \dq :set lz:if &diff:windo set nodiff fdc=0:bw:bd:e #:endif:set nolz
map \dq :execute "call DiffQuit()"<CR>
map \dx :execute "call DiffQuit()"<CR>

let s:diffinfo = ""
nmap <C-S-Right> :call DiffNext('next')
nmap <C-S-Left> :call DiffNext('prev')
nmap <C-S-Up> :call DiffNext('curr')
nmap <C-S-Down> :call DiffQuit()

"------------------------------------------------------------------------------
" File Mappings:
"------------------------------------------------------------------------------
" \fb - does a blame for current file in separate window.
"------------------------------------------------------------------------------
map \fb :call FileBlame()

"------------------------------------------------------------------------------
" Commands:
"------------------------------------------------------------------------------
" Versions  - get log information for current file (ALS/SVN/GIT).
" GitStatus - do a git status for current file or directory (tries file first).
" GitAmmend - ammend to HEAD.
" GitMan    - bring up local git documentation file for a topic.
"------------------------------------------------------------------------------
com! -nargs=0 Versions call Versions()
com! -nargs=1 -complete=custom,GitManComplete GitMan execute "edit " . g:git_doc_dir . "<args>.txt"
com! -range -nargs=0 GitStatus call GitStatus()
com! -range -nargs=0 GitAmmend call GitAmmend()

"------------------------------------------------------------------------------
" Setup variable to represent slash to use for path names for current OS.
"------------------------------------------------------------------------------
if (match(getcwd(), '/'))
   let g:os_slash="\\"
   let g:git_doc_dir="C:\\cygwin\\home\\cforbish\\git\\src\\git\\Documentation\\"
else
   let g:os_slash="/"
   let g:git_doc_dir="~/apps/git-1.5.5.4/Documentation/"
endif

"------------------------------------------------------------------------------
" Determine a good directory to place temporary files.
"------------------------------------------------------------------------------
if (!strlen($VIMTMPDIR))
   if (strlen($VIMHOME))
      if (isdirectory($VIMHOME . g:os_slash . "vimtmp"))
         let $VIMTMPDIR = $VIMHOME . g:os_slash . "vimtmp"
      elseif (isdirectory($VIMHOME . g:os_slash . "tmp"))
         let $VIMTMPDIR = $VIMHOME . g:os_slash . "tmp"
      endif
   elseif (strlen($HOME))
      if (isdirectory($HOME . g:os_slash . "vimtmp"))
         let $VIMTMPDIR = $HOME . g:os_slash . "vimtmp"
      elseif (isdirectory($HOME . g:os_slash . "tmp"))
         let $VIMTMPDIR = $HOME . g:os_slash . "tmp"
      else
         let $VIMTMPDIR = $HOME
      endif
   elseif (g:os_slash == "\\")
      let $VIMTMPDIR = "C:\\WINDOWS\\Temp"
   else
      let $VIMTMPDIR = "~"
   endif
endif

"------------------------------------------------------------------------------
" CanDo
"------------------------------------------------------------------------------
" Simply determine if the command passed in as a:cmd can be run on the current
" system in the current environment.
"------------------------------------------------------------------------------
function! CanDo(cmd)
   let l:result = system(a:cmd)
   return !v:shell_error
endfunction

"------------------------------------------------------------------------------
" AdjustPath
"------------------------------------------------------------------------------
" Make some necessary changes to a file path.
"------------------------------------------------------------------------------
function! AdjustPath(filename)
   let l:filename = system("cygpath " . a:filename)
   if (v:shell_error)
      let l:filename = a:filename
   else
      let l:filename = substitute(l:filename, '\n', '', '')
   endif
   return l:filename
endfunction

"------------------------------------------------------------------------------
" RevisionTypeOfFile
"------------------------------------------------------------------------------
" Get post als revision type for a:filename with is a full path to a file.
"------------------------------------------------------------------------------
function! RevisionTypeOfFile(filename)
   let l:startdir = getcwd()
   let l:dir = substitute(a:filename, '^\(.*\)\' . g:os_slash . '.*', '\1', "g")
   let l:file = substitute(a:filename, '^.*\' . g:os_slash . '\(.*\)', '\1', "g")
   if (strlen(l:dir))
      execute "cd " . l:dir
   endif
   let l:retval = "unknown"
   if (CanDo("git --version"))
      " try git first as it is faster of the three.
      let l:result = system("git ls-files --stage " . l:file . " | head -1")
      if (strlen(l:result) && match(l:result, '^fatal:\|^error:'))
         let l:retval = "git"
      endif
   endif
   if ((l:retval == "unknown") && CanDo("svn --version"))
      " try svn next as it is faster than als.
      let $MOO_ALWAYS_PASSTHRU = 1
      "-----------------------------------------------------
      " Set MOO_ALWAYS_PASSTHRU to get the real svn to
      " function for the info and not the one used by git.
      "-----------------------------------------------------
      let l:filename = AdjustPath(a:filename)
      let l:result = system("svn info " . l:filename . " | head -1")
      if (strlen(l:result) && match(l:result, 'Not a versioned resource\|is not a working copy') < 0)
         let l:retval = "svn"
      endif
      let $MOO_ALWAYS_PASSTHRU = ""
   endif
   if ((l:retval == "unknown") && (strlen($PROJECT)) && ($PROJECT != "MLS"))
      let l:result = system("q " . a:filename)
      if (strlen(l:result) && match(l:result, 'Unable to locate toplevel\|does not exist') < 0)
         let l:retval = "als"
      endif
   endif
   execute "cd " . l:startdir
   return l:retval
endfunction

"------------------------------------------------------------------------------
" RevisionType
"------------------------------------------------------------------------------
" Get post als revision type for the current file (either git or svn)
"------------------------------------------------------------------------------
function! RevisionType()
   return RevisionTypeOfFile(expand("%:p"))
endfunction

"------------------------------------------------------------------------------
" GetTopLevelAbsPathOfPath
"------------------------------------------------------------------------------
" try to determine top level path by searching back for either .toplevel or
" .git at directory of a:filename as full path to file.
"------------------------------------------------------------------------------
function! GetTopLevelAbsPathOfPath(pathname)
   let l:startdir = getcwd()
   if (strlen(a:pathname) && isdirectory(a:pathname))
      execute "cd " . a:pathname
   endif
   let l:svndir = ""
   let l:lastdir = ""
   let l:currdir = getcwd()
   while (!filereadable(".toplevel") && !isdirectory(".git") && (l:currdir != $VIMHOME) && (l:currdir != l:lastdir))
      let l:lastdir = getcwd()
      if (isdirectory(".svn"))
         let l:svndir = l:lastdir
      endif
      cd ..
      if (strlen(l:svndir) && !isdirectory(".svn"))
         execute "cd " . l:currdir
         break
      endif
      let l:currdir = getcwd()
   endwhile
   if (filereadable(".toplevel") || isdirectory(".git") || isdirectory(".svn"))
      let retval = getcwd()
   else
      let retval = ""
   endif
   execute "cd " . l:startdir
   return retval
endfunction

"------------------------------------------------------------------------------
" GetTopLevelAbsPathOfFile
"------------------------------------------------------------------------------
" try to determine top level path by searching back for either .toplevel or
" .git at directory of a:filename as full path to file.
"------------------------------------------------------------------------------
function! GetTopLevelAbsPathOfFile(filename)
   let l:dir = substitute(a:filename, '^\(.*\)\' . g:os_slash . '.*', '\1', "g")
   return GetTopLevelAbsPathOfPath(l:dir)
endfunction

"------------------------------------------------------------------------------
" GetTopLevelAbsPath
"------------------------------------------------------------------------------
" try to determine top level path by searching back for either .toplevel or
" .git at directory of current file
"------------------------------------------------------------------------------
function! GetTopLevelAbsPath()
   return GetTopLevelAbsPathOfFile(expand("%:p"))
endfunction

"------------------------------------------------------------------------------
" BuildTmpFileName
"------------------------------------------------------------------------------
" Build a VIMTMPDIR version of file passed in as full path as a:filename
"------------------------------------------------------------------------------
function! BuildTmpFileName(filename)
   if (g:os_slash == "\\")
      let l:result = substitute(a:filename, '^\(\a\):', '_\1_', "g")
   else
      let l:result = a:filename
   endif
   let l:result = $VIMTMPDIR . g:os_slash . substitute(l:result, g:os_slash, '_', "g")
   return l:result
endfunction

"------------------------------------------------------------------------------
" GitRemoteBranch
"------------------------------------------------------------------------------
" Read from the .git/config file which remote branch is the base for the
" current branch
" Returns a blank result if none found.
"------------------------------------------------------------------------------
function! GitRemoteBranch(toplevel)
   let l:lz = &lz
   set lz
   let l:startdir = getcwd()
   execute "cd " . a:toplevel
   let l:rc = ""
   let l:svninfo = system("git svn info")
   if (match(l:svninfo, '^svn: \|^Use of uninitialized value'))
      let l:url = substitute(l:svninfo, '.*URL: \(.\{-}\)\n.*', '\1', "")
      let l:root = substitute(l:svninfo, '.*Repository Root: \(.\{-}\)\n.*', '\1', "")
      let l:codeline = substitute(l:url, l:root . '/', '', "")
      new
      execute 'sil! r ' a:toplevel . '/.git/config'
      1
      let l:result = search('^\tfetch = ' . l:codeline . ':')
      let l:rc = substitute(getline("."), '.*:refs/remotes/', '', "")
      bw!
   endif
   execute "sil! cd " . l:startdir
   if (!l:lz)
      set nolz
   endif
   return l:rc
endfunction

"------------------------------------------------------------------------------
" BuildFileFromSystemCmd
"------------------------------------------------------------------------------
" This function exists because on cygwin system does not honor a '>' character
" to redirect to a file.
"------------------------------------------------------------------------------
function! BuildFileFromSystemCmd(file, command)
   execute "new " . a:file
   %d
   execute "r !" . a:command
   normal ggdd
   update | close
endfunction

"------------------------------------------------------------------------------
" DiffWithRevisionGit
"------------------------------------------------------------------------------
" Get a difference between current file and some
" version of same file as a:revname using git.
"------------------------------------------------------------------------------
function! DiffWithRevisionGit(revname)
   let l:lz = &lz
   set lz
   let l:gitdir = GetTopLevelAbsPath()
   let l:startdir = getcwd()
   let l:tempfile = BuildTmpFileName(expand("%:p")) . "." . substitute(a:revname, '.*\/', '', 'g')
   let l:errstr = ""
   let l:revtouse = ""
   let l:havetmp = 0
   execute "cd " . l:gitdir
   let l:gitfile = expand("%")
   if (isdirectory("C:\\"))
      let l:gitfile = substitute(expand("%"), '\\', '/', '')
   endif
   if (a:revname == "vim:base")
      call BuildFileFromSystemCmd(l:tempfile, "git show :" . l:gitfile)
      let l:havetmp = 1
   elseif (a:revname == "vim:tlver")
      let l:svnrev = substitute(system("git svn info"), '.*Revision: \(.\{-}\)\n.*', '\1', "")
      let l:revtouse = substitute(system("git svn find-rev r" . l:svnrev), '\n', '', '')
   elseif (a:revname == "vim:daily")
      let l:revtouse = substitute(GitRemoteBranch(l:gitdir), 'master', 'daily', "")
   elseif (a:revname == "vim:core")
      let l:wipurl = substitute(system("git svn info"), '.*URL: \(.\{-}\)\n.*', '\1', "")
      call BuildFileFromSystemCmd(l:tempfile, "svn cat " . l:wipurl . "/" . l:gitfile)
      let l:havetmp = 1
   elseif (a:revname == "vim:master")
      let l:revtouse = GitRemoteBranch(l:gitdir)
      if (!strlen(l:revtouse))
         let l:revtouse = "master"
      endif
   elseif (a:revname == "vim:head")
      let l:revtouse = 'HEAD'
   elseif (a:revname == "vim:bdaily")
      let l:revtouse = substitute(GitRemoteBranch(l:gitdir), 'master', 'lastgood', "")
      if (!match(system("git rev-parse " . l:revtouse), '^fatal:'))
         let l:revtouse = ""
         let l:errstr = "current branch does not support bdaily"
      endif
   else
      let l:revtouse = a:revname
      if (!match(l:revtouse, '^r\d'))
         let l:revtouse = substitute(system("git svn find-rev " . l:revtouse), '\n', '', '')
      endif
   endif
   if (strlen(l:revtouse))
      call BuildFileFromSystemCmd(l:tempfile, "git show " . l:revtouse . ":" . l:gitfile)
      let l:havetmp = 1
   endif
   if (l:havetmp)
      normal gg0
      execute "sil! vert diffsplit " . l:tempfile
      normal hgglgg
      sil! redraw!
   else
      if (!strlen(l:errstr))
         let l:errstr = "cannot determine {sha1} for " . a:revname
      endif
   endif
   execute "sil! cd " . l:startdir
   if (l:lz)
      set lz
   else
      set nolz
   endif
   return l:errstr
endfunction

"------------------------------------------------------------------------------
" DiffWithRevisionSvn
"------------------------------------------------------------------------------
" Get a difference between current file and some
" version of same file as a:revname using svn and mls.
"------------------------------------------------------------------------------
function! DiffWithRevisionSvn(revname)
   let l:lz = &lz
   set lz
   let l:tempfile = BuildTmpFileName(expand("%:p")) . "." . substitute(a:revname, '.*\/', '', 'g')
   if (a:revname == "vim:daily")
      let l:wipurl = system("svn info " . GetTopLevelAbsPath() . " | sed -n 's/URL: //p'")
      let l:revtouse = substitute(system("svn pg mls:daily " . l:wipurl), '\n', '', "g")
   elseif (a:revname == "vim:bdaily")
      let l:wipurl = system("svn info " . GetTopLevelAbsPath() . " | sed -n 's/URL: //p'")
      let l:revtouse = substitute(system("svn pg mls:bdaily " . l:wipurl), '\n', '', "g")
   elseif (a:revname == "vim:tlver")
      let l:systemcmd = "svn info " . GetTopLevelAbsPath() . " | sed -n 's/^Revision: //p'"
      let l:revtouse = substitute(system(l:systemcmd), '\n', '', '')
   else
      if (a:revname == "vim:master")
         let l:revtouse = "head"
      elseif (a:revname == "vim:base")
         let l:revtouse = "base"
      elseif (a:revname == "vim:core")
         let l:revtouse = "head"
      else
         let l:revtouse = a:revname
      endif
   endif
   let l:filename = AdjustPath(expand("%:p"))
   call BuildFileFromSystemCmd(l:tempfile, "svn cat -r " . l:revtouse . " " . l:filename)
   normal gg0
   execute "sil! vert diffsplit " . l:tempfile
   normal hgglgg
   sil! redraw!
   if (l:lz)
      set lz
   else
      set nolz
   endif
endfunction

"------------------------------------------------------------------------------
" GetTopLevelPath
"------------------------------------------------------------------------------
" Find and go to the top level directory of current work space.
"------------------------------------------------------------------------------
function! GetTopLevelPath()
   let l:startdir = getcwd()
   if (strlen(expand("%:h")))
      execute "cd " . expand("%:h")
   endif
   let l:lastdir = ""
   let l:svndir = ""
   let l:filedir = getcwd()
   let l:currdir = l:filedir
   while (!filereadable(".toplevel") && !isdirectory(".git") && (l:currdir != $VIMHOME) && (l:currdir != l:lastdir))
      let l:lastdir = getcwd()
      if (isdirectory(".svn"))
         let l:svndir = l:lastdir
      endif
      cd ..
      if (strlen(l:svndir) && !isdirectory(".svn"))
         execute "cd " . l:currdir
         break
      endif
      let l:currdir = getcwd()
   endwhile
   if (filereadable(".toplevel") || isdirectory(".git") || isdirectory(".svn"))
      let l:currdir = getcwd()
      if (isdirectory("C:\\"))
         let l:currdir = substitute(l:currdir, '\\', '\\\\', "g")
      endif
      let l:retval = substitute(l:filedir, l:currdir . g:os_slash, "", "")
      let l:retval = l:retval . g:os_slash . expand("%:t")
   else
      let l:retval = "."
   endif
   execute "cd " . l:startdir
   return l:retval
endfunction

"------------------------------------------------------------------------------
" DiffWithRevisionAls
"------------------------------------------------------------------------------
" Get a difference between current file and some
" version of same file as a:revname using old als.
"------------------------------------------------------------------------------
function! DiffWithRevisionAls(revname)
   let l:lz = &lz
   set lz
   let l:revtouse = ""
   if ((a:revname == "vim:bdaily") || (a:revname == "vim:daily") || (a:revname == "vim:base") || (a:revname == "vim:tlver"))
      let l:revtouse = "daily"
   elseif ((a:revname == "vim:master") || (a:revname == "vim:head") || (a:revname == "vim:core"))
      let l:revtouse = "core"
   endif
   let l:tempfile = BuildTmpFileName(expand("%:p")) . "." . substitute(l:revtouse, '.*\/', '', 'g')
   if (l:revtouse == "daily")
      if (isdirectory($DAILY))
         execute "sil! !cp $DAILY/" . GetTopLevelPath() . " " . l:tempfile
      else
         echo "Could not find DAILY(" . $DAILY . ") directory."
         let l:tempfile = ""
      endif
   elseif (l:revtouse == "core")
      if (isdirectory($CORE))
         execute "sil! !cp $CORE/" . GetTopLevelPath() . " " . l:tempfile
      else
         echo "Could not find CORE(" . $CORE . ") directory."
         let l:tempfile = ""
      endif
   else
      echo "Could not determine which version to get for " . a:revname
      let l:tempfile = ""
   endif
   if (strlen(l:tempfile))
      normal gg0
      execute "sil! vert diffsplit " . l:tempfile
      normal hgglgg
      sil! redraw!
   endif
   if (l:lz)
      set lz
   else
      set nolz
   endif
endfunction

"------------------------------------------------------------------------------
" DiffQuit
"------------------------------------------------------------------------------
" Use s:diffinfo to determine how to best quit a diff window.
"------------------------------------------------------------------------------
function! DiffQuit()
   let l:lz = &lz
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
   let &lz = l:lz
endfunction

"------------------------------------------------------------------------------
" DiffNext
"------------------------------------------------------------------------------
" Use s:diffinfo to determine last diff method and iterate to next file and
" apply same diff.
"------------------------------------------------------------------------------
function! DiffNext(direction)
   let l:lz = &lz
   set lz
   let l:end = 0
   call DiffQuit()
   if (a:direction == "next")
      if (argidx()+1 >= argc())
         echo "Last file"
         let l:end = 1
      else
         sil! next
      endif
   elseif (a:direction == "prev")
      if (argidx() == 0)
         echo "First file"
         let l:end = 1
      else
         sil! prev
      endif
   endif
   if (!l:end)
      if (!match(s:diffinfo, 'r:'))
         call DiffFileRevision(expand("%:p"), strpart(s:diffinfo, 2))
      elseif (!match(s:diffinfo, 'w:'))
         call DiffWithRevision(strpart(s:diffinfo, 2))
      endif
   endif
   let &lz = l:lz
endfunction

"------------------------------------------------------------------------------
" DiffWithRevision
"------------------------------------------------------------------------------
" Get a difference between current file and some version of same
" file as a:revname using version control system mof current file.
"------------------------------------------------------------------------------
function! DiffWithRevision(revname)
   let l:lz = &lz
   set lz
   let s:diffinfo = 'w:' . a:revname
   let l:revtype = RevisionTypeOfFile(expand("%:p"))
   let l:errstr = ""
   if (l:revtype == "git")
      let l:errstr = DiffWithRevisionGit(a:revname)
   elseif (l:revtype == "svn")
      let l:errstr = DiffWithRevisionSvn(a:revname)
   elseif (l:revtype == "als")
      let l:errstr = DiffWithRevisionAls(a:revname)
   else
      let l:errstr = "do not know repo type of " . expand("%:p") . "."
   endif
   if (strlen(l:errstr))
      echo l:errstr
   endif
   let &lz = l:lz
endfunction

"------------------------------------------------------------------------------
" DiffWithSVNUrl
"------------------------------------------------------------------------------
function! DiffWithSVNUrl(urlpath)
   let l:lz = &lz
   set lz
   if (strpart(a:urlpath, 0, 4) == "http")
      let l:tempfile = BuildTmpFileName(expand("%:p"))
      call BuildFileFromSystemCmd(l:tempfile, "svn cat " . a:urlpath)
      normal gg0
      execute "sil! vert diffsplit " . l:tempfile
      normal hgglgg
      sil! redraw!
   else
      echo '"' . a:urlpath . '" is not a valid svn path.'
   endif
   if (l:lz)
      set lz
   else
      set nolz
   endif
endfunction

"------------------------------------------------------------------------------
" Versions
"------------------------------------------------------------------------------
" Build a temporary file of versions for current file.
" This works for either ALS, SVN or GIT.
"------------------------------------------------------------------------------
function! Versions()
   let l:lz = &lz
   set lz
   let l:fullpath = expand("%:p")
   let l:revtype = RevisionType()
   let l:tempfile = BuildTmpFileName(l:fullpath) . ".versions"
   execute "vnew " . l:tempfile
   %d
   execute "normal iRevisions for file: " . l:fullpath
   if ((!strlen($PROJECT)) || ($PROJECT == "MLS"))
      if (l:revtype == "git")
         let l:startdir = getcwd()
         let l:tl = GetTopLevelAbsPathOfFile(l:fullpath)
         if (!strlen(l:tl))
            echo "Could not determine git toplevel"
            return
         endif
         execute "cd " . l:tl
         let l:gitfile = expand("#")
         if (isdirectory("C:\\"))
            let l:gitfile = substitute(l:gitfile, '\\', '/', '')
         endif
         execute "sil! r !git log " . l:gitfile
         execute "cd " . l:startdir
      else
         sil! r !svn log #
      endif
   else
      sil! r !q #
   endif
   sil! g//s///g
   1
   sil! update
   if (!l:lz)
      set nolz
   endif
endfunction

"------------------------------------------------------------------------------
" DiffFileRevision
"------------------------------------------------------------------------------
" Does a diff on a revision (and previous revision) for a file noted by full
" path name a:file
"------------------------------------------------------------------------------
function! DiffFileRevision(file, revision)
   let l:tmpfile = BuildTmpFileName(a:file)
   let l:newrev = a:revision
   let l:oldrev = ""
   if (stridx(a:revision, '..') > 0)
      let l:oldrev = substitute(a:revision, '\.\..*', '', '')
      let l:newrev = substitute(a:revision, '.*\.\.', '', '')
   elseif (stridx(a:revision, ':') > 0)
      let l:oldrev = substitute(a:revision, ':.*', '', '')
      let l:newrev = substitute(a:revision, '.*:', '', '')
   endif
   if ((!strlen($PROJECT)) || ($PROJECT == "MLS"))
      let l:revtype = RevisionTypeOfFile(a:file)
      if (l:revtype == "git")
         let l:startdir = getcwd()
         let l:tl = GetTopLevelAbsPathOfFile(a:file)
         let l:adjtl = substitute(l:tl, '\\', '/', 'g')
         let l:adjfile = substitute(a:file, '\\', '/', 'g')
         let l:adjfile = substitute(l:adjfile, "^" . l:adjtl . "/", '', "g")
         sil! execute "cd " . l:tl
         if (!match(l:newrev, '^r\d'))
            let l:newrev = substitute(system("git svn find-rev " . l:newrev), '\n', '', '')
         endif
         if (!strlen(l:oldrev))
            let l:oldrev = substitute(system("git rev-parse " . l:newrev . "~"), '\n', '', '')
         elseif (!match(l:oldrev, '^r\d'))
            let l:oldrev = substitute(system("git svn find-rev " . l:oldrev), '\n', '', '')
         endif
         call BuildFileFromSystemCmd(l:tmpfile . "." . l:oldrev, "git show " . l:oldrev . ":" . l:adjfile)
         call BuildFileFromSystemCmd(l:tmpfile . "." . l:newrev, "git show " . l:newrev . ":" . l:adjfile)
         sil! execute "cd " . l:startdir
      else
         if (!strlen(l:oldrev))
            let l:oldrev = l:newrev - 1
         endif
         let l:filename = AdjustPath(a:file)
         call BuildFileFromSystemCmd(l:tmpfile . "." . l:oldrev, "svn cat -r " . l:oldrev . " " . l:filename)
         call BuildFileFromSystemCmd(l:tmpfile . "." . l:newrev, "svn cat -r " . l:newrev . " " . l:filename)
      endif
   else
      if (!strlen(l:oldrev))
         " als has nasty 1.xx version numbers
         let l:oldrev = substitute(l:newrev, '^1.', '', "") - 1
         let l:oldrev = substitute(l:oldrev, '^', '1.', "")
      endif
      sil! execute "!g -O " . l:oldrev . " " . a:file
      sil! execute "!g -O " . l:newrev . " " . a:file
      sil! execute "!mv -f " . a:file . "." . l:oldrev . " " . l:tmpfile . "." . l:oldrev
      sil! execute "!mv -f " . a:file . "." . l:newrev . " " . l:tmpfile . "." . l:newrev
   endif
   let command = "sil! vert diffsplit " . l:tmpfile . "." . l:newrev
   sil! execute "e! " . l:tmpfile . "." . l:oldrev . ""
   sil! execute command
   echo l:tmpfile
   sil! redraw!
endfunction

"------------------------------------------------------------------------------
" DiffVersion
"------------------------------------------------------------------------------
" From a file built by the function versions do a vim diff on revision under
" the cursor.
"------------------------------------------------------------------------------
function! DiffVersion() range
   set lz
   let l:oldr = @r
   if (stridx(getline("1"), "Revisions for file:") < 0)
      let @r = input("Enter revision to diff: ")
      let l:file = expand("%:p")
      let s:diffinfo = 'r:' . @r
   else
      let s:diffinfo = ''
      let l:file = substitute(getline("1"), '^.*: ', '', "g")
      if ((!strlen($PROJECT)) || ($PROJECT == "MLS"))
         let l:revtype = RevisionTypeOfFile(l:file)
         if (l:revtype == "git")
            sil! normal $?^commitw"ry$
         else
            sil! normal $?^r\d "rye
         endif
      else
         sil! normal $?^\s*revisionw"r2ye
      endif
   endif
   sil! hid
   execute 'call DiffFileRevision(l:file, @r)'
   let @r = l:oldr
   set nolz
endfunction

"------------------------------------------------------------------------------
" GitManComplete
"------------------------------------------------------------------------------
" Function to handle auto completing a GitMan command
"------------------------------------------------------------------------------
function! GitManComplete(ArgLead, CmdLine, CursorPos)
   set lz
   let savereg = @+
   new
   execute "r !ls " . g:git_doc_dir
   v/\.txt$/d
   g/\.txt$/s///g
   %y+
   bw!
   let retval = @+
   let @+ = savereg
   set nolz
   return retval
endfunction

"------------------------------------------------------------------------------
" GitStatus
"------------------------------------------------------------------------------
" Do a git status to a temporary file
" It determines which directory to do the status on by:
" 1) Current directory if a git top level.
" 2) Top level of current file if it is part of a git repo.
" 3) Top level of current directory if it is part of a git repo.
"------------------------------------------------------------------------------
function! GitStatus()
   let l:lz = &lz
   set lz
   let l:tl = ''
   if (&mod)
      echo "Current buffer has modifications."
   else
      if (isdirectory(".git"))
         let l:tl = getcwd()
      else
         if (RevisionTypeOfFile(expand("%:p")) == "git")
            let l:tl = GetTopLevelAbsPathOfFile(expand("%:p"))
         else
            let l:tl = GetTopLevelAbsPathOfPath(getcwd())
         endif
      endif
      if (strlen(l:tl))
         execute "cd " . l:tl
         let l:tmpfilename = BuildTmpFileName(getcwd()) . "_git_status"
         execute "edit " . l:tmpfilename
         %d
         r !git status
         update
      else
         echo "Could not determine a top level for current file or current directory"
      endif
   endif
   if (!l:lz)
      set nolz
   endif
endfunction

"------------------------------------------------------------------------------
" GitAmmend
"------------------------------------------------------------------------------
" Ammend to head
"------------------------------------------------------------------------------
function! GitAmmend()
   let l:lz = &lz
   set lz
   let l:tl = ''
   if (&mod)
      echo "Current buffer has modifications."
   else
      if (isdirectory(".git"))
         let l:tl = getcwd()
      else
         if (RevisionTypeOfFile(expand("%:p")) == "git")
            let l:tl = GetTopLevelAbsPathOfFile(expand("%:p"))
         else
            let l:tl = GetTopLevelAbsPathOfPath(getcwd())
         endif
      endif
      if (strlen(l:tl))
         execute "cd " . l:tl
         let l:tmpfilename = BuildTmpFileName(getcwd()) . "_git_ammend"
         if (stridx(expand("%"), expand(l:tmpfilename)))
            execute "edit " . l:tmpfilename
            %d
            sil! r !git whatchanged HEAD~1..HEAD
            sil! v;^    ;d
            sil! g;^    ;s;;;g
            sil! update
         else
            execute "!git commit --amend -F " . @%
            execute "bw!"
         endif
      else
         echo "Could not determine a top level for current file or current directory"
      endif
   endif
   if (!l:lz)
      set nolz
   endif
endfunction

"------------------------------------------------------------------------------
" DiffLineRev
"------------------------------------------------------------------------------
" Does a diff for the revision that caused the last change to the current line
" in the current file.
"------------------------------------------------------------------------------
function! DiffLineRev() range
   if ((!strlen($PROJECT)) || ($PROJECT == "MLS"))
      set lz
      let l:tl = GetTopLevelAbsPath()
      let l:startdir = getcwd()
      execute "cd " . l:tl
      let l:isgit = 0
      let l:lineno = line(".")
      new
      if (isdirectory(l:tl . "/.git"))
         let l:isgit = 1
         sil! r !git blame #
      else
         sil! r !svn blame #
      endif
      1d
      execute l:lineno
      let l:revision = expand("<cWORD>")
      bw!
      if (l:isgit && strpart(l:revision, 0, 1) == "^")
         let l:revision = 0
      endif
      let l:testrev = printf("%u", '0x' . l:revision)
      if ((l:testrev >= 0) && (l:testrev <= 1))
         redraw
         echo "repository for file does not support blame."
      else
         call DiffFileRevision(expand("%:p"), l:revision)
      endif
      execute "cd " . l:startdir
      set nolz
   else
      echo "Sorry, ALS has no concept of blame."
   endif
endfunction

"------------------------------------------------------------------------------
" DiffSnapshot
"------------------------------------------------------------------------------
" Diff current file with same file from yesterday (.snapshot)
"------------------------------------------------------------------------------
function! DiffSnapshot()
   let l:lz = &lz
   set lz
   let l:startdir = getcwd()
   execute "cd"
   execute "sil! vert diffsplit ~/.snapshot/sv_nightly.0/" . expand("%")
   execute "cd " . l:startdir
   sil! redraw!
   if (l:lz)
      set lz
   else
      set nolz
   endif
endfunction

"------------------------------------------------------------------------------
" FileBlame
"------------------------------------------------------------------------------
" Bring up blame window for either git or svn.
"------------------------------------------------------------------------------
function! FileBlame() range
   let l:revtype = RevisionType()
   let l:tempfile = BuildTmpFileName(expand("%:p")) . ".blame"
   if ((!strlen($PROJECT)) || ($PROJECT == "MLS"))
      let l:lz = &lz
      set lz
      let l:startdir = getcwd()
      execute "sil! cd " . expand("%:p:h")
      let lineno = line(".")
      execute "new " . l:tempfile
      sil! %d
      if (l:revtype == "git")
         sil! r !git blame #
      else
         sil! r !svn blame #
      endif
      1d
      update
      execute lineno
      execute "sil! cd " . l:startdir
      if (!l:lz)
         set nolz
      endif
   else
      echo "Sorry, ALS has no concept of blame."
   endif
endfunction

