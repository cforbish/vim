" <AUTO_VIM_SCRIPT_TAG 1> vi: set ft=tcl:
sil! set lz
exe 'r ' . expand("<sfile>")
sil! exec '!chmod +x ' . expand('%')
" setup the '< and '> marks for a range for :g
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal V/^" <AUTO_VIM_SCRIPT_TAG 3V
'<,'>g;\<ccc\>;s;;\=expand("%:t:r");g
" remove all between and including tags 1 and 2
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 1
sil! normal d/^" <AUTO_VIM_SCRIPT_TAG 2dd
" remove tag line 3
sil! normal /^" <AUTO_VIM_SCRIPT_TAG 3dd
sil! 1d
sil! set ff=unix
sil! update | edit
sil! set nolz
finish
" <AUTO_VIM_SCRIPT_TAG 2>
#!/usr/bin/env wish
# vi: set ts=8 sw=4 sts=4 et:

proc main {} {
    puts "Hello World.\n"
}

main

" <AUTO_VIM_SCRIPT_TAG 3>
