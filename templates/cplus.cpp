" <AUTO_VIM_SCRIPT_TAG 1> vi: set ft=vim:
sil! set lz
exe 'r ' . expand("<sfile>")
" setup the '< and '> marks for a range for :g
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal V/^" <AUTO_VIM_SCRIPT_TAG 3V
'<,'>g;\<ccc\>;s;;\=expand("%:t:r");g
set makeprg=g++\ -DCOMPILE_ALONE=1\ -Wall\ -g\ -o\ %:r\ %
" remove all between and including tags 1 and 2
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 1
sil! normal d/^" <AUTO_VIM_SCRIPT_TAG 2dd
" remove tag line 3
sil! normal /^" <AUTO_VIM_SCRIPT_TAG 3dd
sil! 1d
sil! set nolz
sil! update | edit
finish
" <AUTO_VIM_SCRIPT_TAG 2>
// vi: set ts=8 sw=4 sts=4 et:
#include <iostream>

using namespace std;

#if COMPILE_ALONE == 1
int main(int argc, char **argv)
{
    printf("Hello World.\n");
    return 0;
}
#endif

" <AUTO_VIM_SCRIPT_TAG 3>
