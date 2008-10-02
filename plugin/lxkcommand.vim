
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
" T - (\dt) TOP    Diffs against revistion workspace originated from.
" C - (\dc) CORE   Gets latest file from svn and does a diff.
" O - (\do) ORIG   Does a diff with current file and a .orig (ALS)
" L - (\dl) LINE   Does a diff of a revision in which current line changed.
" F - (\df) FILE   Prompts for a file to diff current file against.
" R - (\dr) REV    Works with Versions function (:Diffr diffs specific revision)
" # - (\dx) LAST   Does a diff with current file and last file.
" Q - (\dq) QUIT   Closes diff session and window to the right.
" X - (\dk) KILL   Closes diff session and both windows.
"
"                                 *-*-H
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
map \db :execute "call DiffWithRevision(\"base\")"
map \dh :execute "call DiffWithRevision(\"head\")"
map \dm :execute "call DiffWithRevision(\"master\")"
map \dd :execute "call DiffWithRevision(\"daily\")"
map \dg :execute "call DiffWithRevision(\"bdaily\")"
map \dt :execute "call DiffWithRevision(\"tlver\")"
map \dc :execute "call DiffWithRevision(\"core\")"
map \do :vert diffsplit %.orig
map \dl :execute "call DiffLineRev()"
map \df :vert diffsplit 
map \dr :execute "call DiffVersion()"
map \d# :vert diffsplit #:windo normal gg
map \dq :set lz:if &diff:windo set nodiff fdc=0:bw:bd:e #:endif:set nolz
map \dx :set lz:if &diff:windo bw!:endif:set nolz

"------------------------------------------------------------------------------
" File Mappings:
"------------------------------------------------------------------------------
" \fb - does a blame for current file in separate window.
"------------------------------------------------------------------------------
map \fb :call FileBlame()

"------------------------------------------------------------------------------
" Commands:
"------------------------------------------------------------------------------
" Versions  - get log information for current file (ALS/MLS/GIT).
" GitStatus - do a git status for current file or directory (tries file first).
" GitMan    - bring up local git documentation file for a topic.
"------------------------------------------------------------------------------
com! -nargs=0 Versions call Versions()
com! -nargs=1 -complete=custom,GitManComplete GitMan execute "edit " . g:git_doc_dir . "<args>.txt"
com! -range -nargs=0 GitStatus call GitStatus()

"------------------------------------------------------------------------------
" Setup variable to represent slash to use for path names for current OS.
"------------------------------------------------------------------------------
if (isdirectory("C:\\"))
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
		let l:result = system("svn info " . a:filename . " | head -1")
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
" This function exists because on cygwin system does no honor a '>' character
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
	if (a:revname == "base")
      call BuildFileFromSystemCmd(l:tempfile, "git show :" . l:gitfile)
		let l:havetmp = 1
	elseif (a:revname == "tlver")
		let l:svnrev = substitute(system("git svn info"), '.*Revision: \(.\{-}\)\n.*', '\1', "")
		let l:revtouse = substitute(system("git svn find-rev r" . l:svnrev), '\n', '', '')
	elseif (a:revname == "daily")
		let l:revtouse = substitute(GitRemoteBranch(l:gitdir), 'master', 'daily', "")
	elseif (a:revname == "core")
		let l:wipurl = substitute(system("git svn info"), '.*URL: \(.\{-}\)\n.*', '\1', "")
      call BuildFileFromSystemCmd(l:tempfile, "svn cat " . l:wipurl . "/" . l:gitfile)
      let l:havetmp = 1
	elseif (a:revname == "master")
		let l:revtouse = GitRemoteBranch(l:gitdir)
		if (!strlen(l:revtouse))
			let l:revtouse = "master"
		endif
	elseif (a:revname == "head")
		let l:revtouse = 'HEAD'
	elseif (a:revname == "bdaily")
		let l:revtouse = substitute(GitRemoteBranch(l:gitdir), 'master', 'lastgood', "")
		if (!match(system("git rev-parse " . l:revtouse), '^fatal:'))
			let l:revtouse = ""
			let l:errstr = "current branch does not support bdaily"
		endif
	else
		let l:revtouse = a:revname
	endif
	if (strlen(l:revtouse))
		call BuildFileFromSystemCmd(l:tempfile, "git show " . l:revtouse . ":" . l:gitfile)
		let l:havetmp = 1
   endif
   if (l:havetmp)
      normal gg0
      execute "vert diffsplit " . l:tempfile
      normal hgglgg
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
" DiffWithRevisionMls
"------------------------------------------------------------------------------
" Get a difference between current file and some
" version of same file as a:revname using svn and mls.
"------------------------------------------------------------------------------
function! DiffWithRevisionMls(revname)
	let l:lz = &lz
	set lz
	let l:tempfile = BuildTmpFileName(expand("%:p")) . "." . substitute(a:revname, '.*\/', '', 'g')
	if (a:revname == "daily")
		let l:wipurl = system("svn info " . GetTopLevelAbsPath() . " | sed -n 's/URL: //p'")
		let l:revtouse = substitute(system("svn pg mls:daily " . l:wipurl), '\n', '', "g")
	elseif (a:revname == "bdaily")
		let l:wipurl = system("svn info " . GetTopLevelAbsPath() . " | sed -n 's/URL: //p'")
		let l:revtouse = substitute(system("svn pg mls:bdaily " . l:wipurl), '\n', '', "g")
	elseif (a:revname == "tlver")
		let l:systemcmd = "svn info " . GetTopLevelAbsPath() . " | sed -n 's/^Revision: //p'"
		let l:revtouse = substitute(system(l:systemcmd), '\n', '', '')
	else
		if (a:revname == "master")
			let l:revtouse = "head"
		elseif (a:revname == "core")
			let l:revtouse = "head"
		else
			let l:revtouse = a:revname
		endif
	endif
	execute "sil! !svn cat -r " . l:revtouse . " " . expand("%:p") . " > " . l:tempfile
	normal gg0
	execute "vert diffsplit " . l:tempfile
	normal hgglgg
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
	if ((a:revname == "bdaily") || (a:revname == "daily") || (a:revname == "base") || (a:revname == "tlver"))
		let l:revtouse = "daily"
	elseif ((a:revname == "master") || (a:revname == "head") || (a:revname == "core"))
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
		execute "vert diffsplit " . l:tempfile
		normal hgglgg
	endif
	if (l:lz)
		set lz
	else
		set nolz
	endif
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
	let l:revtype = RevisionTypeOfFile(expand("%:p"))
	let l:errstr = ""
	if (l:revtype == "git")
		let l:errstr = DiffWithRevisionGit(a:revname)
	elseif (l:revtype == "svn")
		let l:errstr = DiffWithRevisionMls(a:revname)
	elseif (l:revtype == "als")
		let l:errstr = DiffWithRevisionAls(a:revname)
	else
		let l:errstr = "do not know what type of version control handles current file."
	endif
	if (strlen(l:errstr))
		echo l:errstr
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
" This works for either ALS, MLS(SVN) or GIT.
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
			if (!strlen(l:oldrev))
				let l:oldrev = substitute(system("git rev-parse " . a:revision . "~"), '\n', '', '')
			endif
			sil! execute "!git show " . l:oldrev . ":" . l:adjfile . " > " . l:tmpfile . "." . l:oldrev
			sil! execute "!git show " . l:newrev . ":" . l:adjfile . " > " . l:tmpfile . "." . l:newrev
			sil! execute "cd " . l:startdir
		else
			if (!strlen(l:oldrev))
				let l:oldrev = l:newrev - 1
			endif
			sil! execute "!svn cat -r " . l:oldrev . " " . a:file . " > " . l:tmpfile . "." . l:oldrev
			sil! execute "!svn cat -r " . l:newrev . " " . a:file . " > " . l:tmpfile . "." . l:newrev
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
	let command = "vert diffsplit " . l:tmpfile . "." . l:newrev
	sil! execute "e! " . l:tmpfile . "." . l:oldrev . ""
	sil! execute command
	echo l:tmpfile
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
		echo "Not in a version type file"
		return
	endif
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
"------------------------------------------------------------------------------
function! GitStatus()
	set lz
   let l:tl = GetTopLevelAbsPathOfFile(expand("%:p"))
   if (!strlen(l:tl))
      let l:tl = GetTopLevelAbsPathOfPath(getcwd())
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
	set nolz
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
			echo "this line predates MLS."
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
" FileBlame
"------------------------------------------------------------------------------
" Bring up blame window for either git or svn.
"------------------------------------------------------------------------------
function! FileBlame() range
	let l:revtype = RevisionType()
	let l:tempfile = BuildTmpFileName(expand("%:p")) . ".blame"
	if ((!strlen($PROJECT)) || ($PROJECT == "MLS"))
		set lz
		let lineno = line(".")
		execute "new " . l:tempfile
		if (l:revtype == "git")
			sil! r !git blame #
		else
			sil! r !svn blame #
		endif
		1d
		update
		execute lineno
	else
		echo "Sorry, ALS has no concept of blame."
	endif
endfunction

