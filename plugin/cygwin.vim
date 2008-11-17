
if (v:version < 600)
	echo "version 6 or greater of vim required for lxkcommands."
	finish
endif

function! ExpandLine()
	return getline(".")
endfunction

function! Cygwpath(path)
	let l:retval = a:path
	let l:retval = substitute(l:retval, '/', '\', "g")
	let l:retval = substitute(l:retval, '^\', 'C:\\cygwin\', "g")
	return l:retval
endfunction

function! Cygcpath(path)
	let l:retval = a:path
	let l:retval = substitute(l:retval, '/', '\', "g")
endfunction

