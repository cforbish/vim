
autocmd!

if ($OSTYPE == "cygwin")
	set shell=C:\WINDOWS\system32\cmd.exe
	" let $VIMRUNTIME="c:\\cygwin\\usr\\share\\vim\\vim70"
	" let $VIMRUNTIME="C:\Program Files\Vim\vim71"
	" let $VIMRUNTIME="/cygdrive/c/Program\ Files/Vim/vim71"
endif

source $HOME/vim_scripts/settings.vim
source $HOME/vim_scripts/mappings.vim
source $HOME/vim_scripts/commands.vim
source $HOME/vim_scripts/function.vim
source $HOME/vim_scripts/color.vim
source $HOME/vim_scripts/man.vim
source $HOME/vim_scripts/tlist.vim
source $HOME/vim_scripts/plugin/lxkcommand.vim

