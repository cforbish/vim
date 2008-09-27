
if (v:version < 600)
	echo "version 6 or greater of vim required for lxkcommands."
	finish
endif

map \db :execute "call DiffWithRevision(\"base\")"
map \dd :execute "call DiffWithRevision(\"daily\")"
map \dc :execute "call DiffWithRevision(\"core\")"
map \dh :execute "call DiffWithRevision(\"head\")"
map \dm :execute "call DiffWithRevision(\"master\")"
map \dt :execute "call DiffWithRevision(\"tlver\")"
map \dy :execute "call DiffWithRevision(\"bdaily\")"
" map \ds :execute "call DiffSnapshot()"
" map \dl :execute "call DiffLineRev()"
map \dr :execute "call DiffVersion()"
map \df :vert diffsplit 
map \do :vert diffsplit %.orig
map \dq :set lz:if &diff:windo set nodiff fdc=0:wincmd l:clo:endif:set nolz
map \dw :set lz:if &diff:windo set nodiff fdc=0:bw:bd:e #:endif:set nolz
map \dx :set lz:if &diff:windo bw!:endif:set nolz
map \dn :set lz:if &diff:windo set nodiff fdc=0:endif:set nolz
map \d# :vert diffsplit #:windo normal gg

com! -nargs=0 Versions call Versions()

"------------------------------------------------------------------------------
" Setup variable to represent slash to use for path names for current OS.
"------------------------------------------------------------------------------
if (isdirectory("C:\\"))
	let g:os_slash="\\"
else
	let g:os_slash="/"
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
	let l:gitfile = expand("%")
	if (isdirectory("C:\\"))
		let l:gitfile = substitute(expand("%"), '\\', '/', '')
	endif
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
			if (!strlen(l:oldrev))
				let l:oldrev = substitute(system("git rev-parse " . a:revision . "~"), '\n', '', '')
			endif
			let l:startdir = getcwd()
			let l:tl = GetTopLevelAbsPathOfFile(a:file)
			let l:adjtl = substitute(l:tl, '\\', '/', 'g')
			let l:adjfile = substitute(a:file, '\\', '/', 'g')
			let l:adjfile = substitute(l:adjfile, "^" . l:adjtl . "/", '', "g")
			sil! execute "cd " . l:adjtl
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

