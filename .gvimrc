
set guioptions+=b
set guioptions-=T
set columns=94

if (has("win32unix"))
    let $nodosfilewarning="1"
    set guifont=LucidaTypewriter\ Medium\ 7
    colorscheme koehler
    syntax on
    set lines=59
else
    set guifont=Lucida_Console:h7:cANSI
    set lines=69
endif

