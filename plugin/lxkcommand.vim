
command! -nargs=0 Versions call s:Versions()

command! Versions call s:Versions()
nnoremap <unique> <Plug>Versions :Versions<CR>
nmap <unique> \dr :execute "call DiffVersion()"

" command! GITAdd call s:GITAdd()
" nnoremap <unique> <Plug>GITAdd :GITAdd<CR>
" if !hasmapto('<Plug>GITAdd')
"   nmap <unique> <Leader>ga <Plug>GITAdd
" endif
" amenu <silent> &Plugin.GIT.&Add      <Plug>GITAdd

if (isdirectory("C:\\"))
	let g:os_slash="\\"
else
	let g:os_slash="/"
endif

if (!strlen($VIMTMPDIR))
	if (isdirectory($VIMHOME . g:os_slash . "vimtmp"))
		let $VIMTMPDIR = $VIMHOME . g:os_slash . "vimtmp"
	elseif (isdirectory($VIMHOME . g:os_slash . "tmp"))
		let $VIMTMPDIR = $VIMHOME . g:os_slash . "tmp"
	elseif (isdirectory($HOME . g:os_slash . "vimtmp"))
		let $VIMTMPDIR = $HOME . g:os_slash . "vimtmp"
	elseif (isdirectory($HOME . g:os_slash . "tmp"))
		let $VIMTMPDIR = $HOME . g:os_slash . "tmp"
	elseif (g:os_slash == "\\")
		let $VIMTMPDIR = "C:\\WINDOWS\\Temp"
	else
		let $VIMTMPDIR = $HOME
	endif
endif

"------------------------------------------------------------------------------
" CanDo
"------------------------------------------------------------------------------
" Simply determine if the command passed in as a:cmd can be run on the current
" system in the current environment.
"------------------------------------------------------------------------------
function! s:CanDo(cmd)
	let l:result = system(a:cmd)
	return !v:shell_error
endfunction

"------------------------------------------------------------------------------
" GetTopLevelAbsPathOfFile
"------------------------------------------------------------------------------
" try to determine top level path by searching back for either .toplevel or
" .git at directory of a:filename as full path to file.
"------------------------------------------------------------------------------
function! s:GetTopLevelAbsPathOfFile(filename)
	let l:startdir = getcwd()
	let l:dir = substitute(a:filename, '^\(.*\)\' . g:os_slash . '.*', '\1', "g")
	if (strlen(l:dir))
		execute "cd " . l:dir
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
" BuildTmpFileName
"------------------------------------------------------------------------------
" Build a VIMTMPDIR version of file passed in as full path as a:filename
"------------------------------------------------------------------------------
function! s:BuildTmpFileName(filename)
	if (g:os_slash == "\\")
		let l:result = substitute(a:filename, '^\(\a\):', '_\1_', "g")
	else
		let l:result = a:filename
	endif
	let l:result = $VIMTMPDIR . g:os_slash . substitute(l:result, g:os_slash, '_', "g")
	return l:result
endfunction

"------------------------------------------------------------------------------
" RevisionTypeOfFile
"------------------------------------------------------------------------------
" Get post als revision type for a:filename with is a full path to a file.
"------------------------------------------------------------------------------
function! s:RevisionTypeOfFile(filename)
	let l:startdir = getcwd()
	let l:dir = substitute(a:filename, '^\(.*\)\' . g:os_slash . '.*', '\1', "g")
	if (strlen(l:dir))
		execute "cd " . l:dir
	endif
	let l:retval = "unknown"
	if (s:CanDo("git --version"))
		" try git first as it is faster of the three.
		let l:result = system("git-ls-files --stage " . a:filename . " | head -1")
		if (strlen(l:result) && match(l:result, '^fatal:\|^error:'))
			let l:retval = "git"
		endif
	endif
	if ((l:retval == "unknown") && s:CanDo("svn --version"))
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
function! s:RevisionType()
	return s:RevisionTypeOfFile(expand("%:p"))
endfunction

"------------------------------------------------------------------------------
" Versions
"------------------------------------------------------------------------------
" Build a temporary file of versions for current file.
" This works for either ALS, MLS(SVN) or GIT.
"------------------------------------------------------------------------------
function! s:Versions()
	set lz
	let l:fullpath = expand("%:p")
	let l:revtype = s:RevisionType()
	let l:tempfile = s:BuildTmpFileName(l:fullpath) . ".versions"
	execute "vnew " . l:tempfile
	%d
	execute "normal iRevisions for file: " . l:fullpath
	if ((!strlen($PROJECT)) || ($PROJECT == "MLS"))
		if (l:revtype == "git")
			let l:startdir = getcwd()
			let l:tl = s:GetTopLevelAbsPathOfFile(l:fullpath)
			if (!strlen(l:tl))
				echo "Could not determine git toplevel"
				return
			endif
			execute "cd " . l:tl
			sil! r !git log #
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
	set nolz
endfunction

