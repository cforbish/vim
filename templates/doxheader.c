" <AUTO_VIM_SCRIPT_TAG 1> vi: set ft=vim:
sil! set lz
" save off register a
let savepaste=&paste
set paste
" cursor to then save off function name
normal 0f(b
let fname=expand("<cword>")
let linestr=getline(".")
sil! normal ebb
" save off function type
sil! let ftype=expand("<cword>")
sil! normal f(w
" register a becomes argument list
sil! normal k
" read this file into current file
exe 'r ' . expand("<sfile>")
" new code here
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal /ppp
let matchpattern="[,()]"
let linestr=strpart(linestr, matchend(linestr, matchpattern))
while (match(linestr, matchpattern) > 0)
	let linepart=substitute(linestr, '^\s*', '', "")
	let linepart=substitute(strpart(linepart, 0, match(linepart, matchpattern)), '\(.*\) \(.*\)', '\2: \1', "")
	let linestr=strpart(linestr, matchend(linestr, matchpattern))
	exe "sil! normal o * @param    " . linepart
endwhile
" setup the '< and '> marks for a range for :g
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal V/^" <AUTO_VIM_SCRIPT_TAG 3V
'<,'>g/\<fff\>/s//\=fname/g
'<,'>g/\<ttt\>/s//\=ftype/g
'<,'>g/\<ppp\>/d
'<,'>g;\<uuu\>;s;;\=$USER;g
'<,'>g;\<mm/dd/yy\>;s;;\=strftime("%m/%d/%y");g
" remove all between and including tags 1 and 2
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 1
sil! normal d/^" <AUTO_VIM_SCRIPT_TAG 2dd
" remove tag line 3
sil! normal /^" <AUTO_VIM_SCRIPT_TAG 3dd
" cleanup
let &paste=savepaste
exe 'bw ' . expand("<sfile>")
normal {z
/TODO
normal w
sil! set nolz
finish
" <AUTO_VIM_SCRIPT_TAG 2>
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * fff
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * @brief
 *           TODO give me a purpose
 *
 * @author   uuu
 * @date     mm/dd/yy
 * @return   ttt
 * ppp
 *
 * Output:        \n
 * Globals Read:  \n
 * Globals Set:   \n
 *~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
" <AUTO_VIM_SCRIPT_TAG 3>
