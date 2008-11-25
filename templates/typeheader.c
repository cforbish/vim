" <AUTO_VIM_SCRIPT_TAG 1> vi: set ft=vim:
sil! set lz
" save off function name
let tname=expand("<cword>")
sil! normal k
" read this file into current file
exe 'r ' . expand("<sfile>")
" setup the '< and '> marks for a range for :g
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal V/^" <AUTO_VIM_SCRIPT_TAG 3V
'<,'>g/\<ttt\>/s//\=tname/g
" remove all between and including tags 1 and 2
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 1
sil! normal d/^" <AUTO_VIM_SCRIPT_TAG 2dd
" remove tag line 3
sil! normal /^" <AUTO_VIM_SCRIPT_TAG 3dd
" cleanup
exe 'bw ' . expand("<sfile>")
sil! set nolz
finish
" <AUTO_VIM_SCRIPT_TAG 2>
/*******************************************************************************
 * ttt
 ******************************************************************************/
" <AUTO_VIM_SCRIPT_TAG 3>
