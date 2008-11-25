
if (v:version >= 600)
	map _9 :setl ts=79:setl sw=3:setl sts=3:set ts ?
	map _8 :setl ts=8:setl sw=8:setl sts=8:set ts ?
	map _7 :setl ts=8:setl sw=4:setl sts=4:set ts ?
	map _6 :setl ts=8:setl sw=3:setl sts=3:set ts ?
	map _5 :setl ts=8:setl sw=2:setl sts=2:set ts ?
	map _4 :setl ts=4:setl sw=4:setl sts=4:set ts ?
	map _3 :setl ts=3:setl sw=3:setl sts=3:set ts ?
	map _2 :setl ts=2:setl sw=2:setl sts=2:set ts ?
	map _1 :setl ts=6:setl sw=3:setl sts=3:set ts ?
else
	map _9 :set ts=79:set sw=3:set sts=3:set ts ?
	map _8 :set ts=8:set sw=8:set sts=8:set ts ?
	map _7 :set ts=8:set sw=4:set sts=4:set ts ?
	map _6 :set ts=8:set sw=3:set sts=3:set ts ?
	map _5 :set ts=8:set sw=2:set sts=2:set ts ?
	map _4 :set ts=4:set sw=4:set sts=4:set ts ?
	map _3 :set ts=3:set sw=3:set sts=3:set ts ?
	map _2 :set ts=2:set sw=2:set sts=2:set ts ?
	map _1 :set ts=6:set sw=3:set sts=3:set ts ?
endif
map <c-n> :cn<CR>
map <c-p> :cp<CR>
nmap <C-Down> :tn<CR>
nmap <C-Up> :tN<CR>
nmap <c-right> :n<CR>
nmap <c-left> :N<CR>
map \ff :e w:/tmp/foo
map \fb :e $HOME/.bashrc
map \fc :e $HOME/.cshrc
map \fv :e $HOME/vim_scripts/.vimrc
map \fa :so W:\mystuff\vimstuff\nba\sourceme.vim:cd %:h
map \fn :so W:\mystuff\vimstuff\nascar\sourceme.vim:cd %:h
map \fo :so W:\mystuff\vimstuff\nfl\sourceme.vim:cd %:h
map \fp :so c:\mystuff\otherstuff\phdir\vim\phsource.vim:cd %:h
map \st :source $HOME/vim_scripts/togcolor.vim
"Toggles search highlighting.
map \h :set invhls: set hls ?
"Toggles line numbering.
map \n :set invnu: set nu ?
"Toggles paste mode
map \p :set invpaste: set paste ?
"Toggles expandtab
map \e :set invet: set et ?
map _> :call RegsToStar()
map _< :call StarToRegs()
map _+ :call SelectionToRegs()
map _= :call LabelRegs()
map _- :call CleanRegs()
map \v `<V`>

map \cs :so ~/vim_scripts/templates/main.c
map \c+ :so ~/vim_scripts/templates/cplus.cpp
map \cc :so ~/vim_scripts/templates/class.cpp
map \cj :so ~/vim_scripts/templates/java.java
map \cp :so ~/vim_scripts/templates/perl.pl
map \sf :so ~/vim_scripts/templates/
map _H :so ~/vim_scripts/templates/doxheader.c

if (v:version >= 600)
	map \sp :call IspellRegion()
	map \sr :call RegsToStar()
	map \ss :call StarToRegs()
	map _D* :let @*=strftime("%m-%d-%y")
endif

if (&shell == "/bin/sh")
	map _A :let@/="\\<\\>":grep "/" [!XY]*
	map _B :let@/="\\<\\>":grep "/" `find . -name '[!XY]*' -a ! -name '*.svn*'`
	map _F :let@/="\\<\\>":grep "/" [!XY]*.[ch] [!XY]*.cc [!XY]*.cpp
	map _J :let@/="\\<\\>":grep "/" [!XY]*.java
	map _X :let@/="\\<\\>":grep "/" `find . -name '[!XY]*.[ch]' -o -name '[!XY]*.cpp'`
else
	map _A :let@/="\\<\\>":grep "/" [^XY]*
	map _B :let@/="\\<\\>":grep "/" `find . -name '[^XY]*' -a ! -name '*.svn*'`
	map _F :let@/="\\<\\>":grep "/" [^XY]*.[ch] [^XY]*.cc *[^XY]*.cpp
	map _J :let@/="\\<\\>":grep "/" [^XY]*.java
	map _X :let@/="\\<\\>":grep "/" `find . -name '[^XY]*.[ch]' -o -name '[^XY]*.cpp'`
endif

com! -nargs=1 BwPattern call BwPattern(<f-args>)

