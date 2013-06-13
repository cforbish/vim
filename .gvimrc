
set guioptions+=b
set guioptions-=T
set columns=94

if (has("win32unix"))
    let $nodosfilewarning="1"
    set guifont=LucidaTypewriter\ Medium\ 9
    colorscheme koehler
    syntax on
    set lines=69
else
    set guifont=Lucida_Console:h7:cANSI
    set lines=69
endif

