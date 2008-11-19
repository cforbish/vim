
"-------------------------------------------------------------------------------
" Stuff done to get 6.3 working
"-------------------------------------------------------------------------------
set nocompatible
set history=100
" set grepprg=grep\ -n\ $*\ /dev/null

set viminfo=""

set tildeop
set wildmenu
set wildmode=longest:full
set wildchar=<Tab>
set completeopt=preview

set nows
set ic
set ai
set makeprg=g++\ -Wall\ -g\ -o\ %:r\ %
set splitright
set ruler
set nowrap

set tabstop=3
set shiftwidth=3
set softtabstop=3

set tags=./tags,tags,~/tags/tags

set showmatch

