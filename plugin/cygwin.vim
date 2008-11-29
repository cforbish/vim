
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

"------------------------------------------------------------------------------
" Cygwpath
"------------------------------------------------------------------------------
" Convert a path to a windows path
"------------------------------------------------------------------------------
function! Cygwpath(path)
	let l:retval = system("cygpath -w " . a:path)
	return l:retval
endfunction

"------------------------------------------------------------------------------
" Cygcpath
"------------------------------------------------------------------------------
" Convert a path to a linux path
"------------------------------------------------------------------------------
function! Cygcpath(path)
	let l:retval = system("cygpath " . a:path)
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
			let l:command = l:command . ' ' . Cygcpath(l:arg)
		else
			let l:command = l:command . ' ' . l:arg
		endif
	endfor
	echo system(l:command)
endfunction

