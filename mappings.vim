" vi:set ts=3 sts=3 sw=3 ft=vim et:

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

"-------------------------------------------------------------------------------
" Function key mappings
"-------------------------------------------------------------------------------
nmap <F5> :let @+=substitute(getline('.'), '^["#] \\|^!', '', '')<CR>
nmap <F6> :exec '!'.getline('.')
nmap <F7> :exec append(line('.'), split(system(getline('.')), '[\n\r]\+'))

"-------------------------------------------------------------------------------
" Toggling mappings
"-------------------------------------------------------------------------------
"Toggle autoindent
nmap \ta :setl invai: set ai ?
"Toggle search highlighting.
nmap \th :set invhls: set hls ?
map \h :set invhls: set hls ?
"Toggle ignorecase
nmap \ti :setl invic: set ic ?
"Toggle line numbering.
nmap \tn :setl invnumber: set number ?
"Toggle paste mode
nmap \tp :setl invpaste: set paste ?
"Toggle spell checking
nmap \ts :setl invspell: set spell ?
"Toggle wrap mode
nmap \tw :setl invwrap: set wrap ?
"Toggle lazyredraw
nmap \tz :setl invlz: set lz ?

"-------------------------------------------------------------------------------
" Browser mappings
"-------------------------------------------------------------------------------
if (match(getcwd(), '/'))
   nmap \bi :update<CR>:exec '!start c:\progra~2\intern~1\iexplore.exe ' . expand("<cWORD>")<CR>
   nmap \bf :update<CR>:exec '!start C:\progra~2\mozill~1\firefox.exe ' . expand("<cWORD>")<CR>
   nmap \bs :update<CR>:exec '!start C:\progra~2\SeaMonkey\seamonkey.exe ' . expand("<cWORD>")<CR>
   nmap \bc :update<CR>:exec '!start "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" ' . expand("<cWORD>") . ' --start-maximized'<CR>
else
   nmap \bf :update<CR>:exec '!/cygdrive/c/Program\ Files\ \(x86\)/Mozilla\ Firefox/firefox.exe ' . expand("<cWORD>")<CR>
   nmap \bs :update<CR>:exec '!/cygdrive/c/Program\ Files\ \(x86\)/SeaMonkey/seamonkey.exe ' . expand("<cWORD>")<CR>
   nmap \bc :update<CR>:exec '!/cygdrive/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe ' . expand("<cWORD>")<CR>
endif

"-------------------------------------------------------------------------------
" Control key mappings
"-------------------------------------------------------------------------------
map <c-n> :cn<CR>
map <c-p> :cp<CR>
nmap <C-Down> :tn<CR>
nmap <C-Up> :tN<CR>
nmap <c-right> :n<CR>
nmap <c-left> :N<CR>

"-------------------------------------------------------------------------------
" File mappings
"-------------------------------------------------------------------------------
map \ff :e C:/tmp/foo
map \fb :e $HOME/.bashrc
map \fc :e $HOME/.cshrc
map \fv :e $HOME/vim/.vimrc
map \fa :so C:\mystuff\vimstuff\nba\sourceme.vim:cd %:h
map \fn :so C:\mystuff\vimstuff\nascar\sourceme.vim:cd %:h
map \fe :so C:\mystuff\documents\Vba\sourceme.vim
map \fq :so C:\mystuff\documents\Queries\sourceme.vim
map \fo :so C:\mystuff\vimstuff\nfl\sourceme.vim:cd %:h
map \fp :so c:\mystuff\otherstuff\phdir\vim\phsource.vim:cd %:h$
map \fx :e p:\foo

"-------------------------------------------------------------------------------
" Compiler mappings
"-------------------------------------------------------------------------------
map \gc :set makeprg=gcc\ -DCOMPILE_ALONE=1\ -Wall\ -g\ -o\ %:r\ %
map \g+ :set makeprg=g++\ -DCOMPILE_ALONE=1\ -Wall\ -g\ -o\ %:r\ %

"-------------------------------------------------------------------------------
" More mappings
"-------------------------------------------------------------------------------
map \st :source $HOME/vim/togcolor.vim
map _> :call RegsToStar()
map _< :call StarToRegs()
map _+ :call SelectionToRegs()
map _= :call LabelRegs()
map _- :call CleanRegs()
map \v `<V`>

vmap <silent> \/ :call SearchBuild('visual', 'pattern')<CR>
vmap <silent> \? :call SearchBuild('visual', 'pattern')<CR>
vmap <silent> \* :call SearchBuild('visual', 'word')<CR>
vmap <silent> \# :call SearchBuild('visual', 'word')<CR>

nmap <silent> \/ :call SearchBuild('normal', 'pattern')<CR>
nmap <silent> \? :call SearchBuild('normal', 'pattern')<CR>
nmap <silent> \* :call SearchBuild('normal', 'word')<CR>
nmap <silent> \# :call SearchBuild('normal', 'word')<CR>

map \cs :so ~/vim/templates/main.c
map \c+ :so ~/vim/templates/cplus.cpp
map \cc :so ~/vim/templates/class.cpp
map \cj :so ~/vim/templates/java.java
map \cp :so ~/vim/templates/perl.pl
map \sf :so ~/vim/templates/
map _H :so ~/vim/templates/typeheader.c

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
com! -nargs=0 BwNoFile call BwNoFile()
com! -nargs=0 BwTmp call BwTmp()
com! -nargs=0 BwDups call BwDups()

