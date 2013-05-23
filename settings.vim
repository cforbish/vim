" vi:set ts=3 sts=3 sw=3 ft=vim et:

"-------------------------------------------------------------------------------
" Stuff done to get 6.3 working
"-------------------------------------------------------------------------------
set nocompatible
set history=100

set viminfo=""

set tildeop
set wildmenu
set wildmode=longest:full
set wildchar=<Tab>
set completeopt=preview

set nowrapscan
set ignorecase
set autoindent
set makeprg=g++\ -Wall\ -g\ -o\ %:r\ %
set splitright
set ruler
set nowrap

set tabstop=8
set shiftwidth=4
set softtabstop=4
set expandtab

" set shortmess=filnxtToOA

set tags=./tags,tags,~/tags/tags
set cdpath=,$HOME
set path=,

set showmatch

set includeexpr=IncludeExpr(v:fname)
" set directory=.,C:\cygwin\home\cforbish\vimtmp

