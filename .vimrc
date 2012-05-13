" vi:set ts=3 sts=3 sw=3 ft=vim et:

function! PatchEcho(format)
   execute "new C:\\cygwin\\home\\cforbish\\vimtmp\\patch.txt"
   let l:failed = append(line('$'), a:format)
   sil! update | close
endfunction

autocmd!

if ($OSTYPE == "cygwin")
   set shell=C:\WINDOWS\system32\cmd.exe
   " let $VIMRUNTIME="c:\\cygwin\\usr\\share\\vim\\vim70"
   " let $VIMRUNTIME="C:\Program Files\Vim\vim71"
   " let $VIMRUNTIME="/cygdrive/c/Program\ Files/Vim/vim71"
endif

"------------------------------------------------------------------------------
" Setup cygwin only type stuff.
"------------------------------------------------------------------------------
if (match(getcwd(), '/'))
   if (has("win32unix"))
      let $VIMRUNTIME="C:\\cygwin\\usr\\share\\vim\\vim72"
   endif
   if (filereadable('C:\cygwin\bin\bash.exe'))
      " This under evaluation
      set shell=C:/cygwin/bin/bash
      set shellcmdflag=-c
      set shellxquote=\"
   else
      set shell=C:\Windows\system32\cmd.exe
      set shellcmdflag=/c
      set shellxquote=""
   endif
   set includeexpr=AdjustPath(v:fname)
endif

source $HOME/vim_scripts/settings.vim
source $HOME/vim_scripts/mappings.vim
source $HOME/vim_scripts/commands.vim
source $HOME/vim_scripts/function.vim
source $HOME/vim_scripts/color.vim
source $HOME/vim_scripts/man.vim
source $HOME/vim_scripts/tlist.vim
source $HOME/vim_scripts/plugin/lxkcommand.vim
source $HOME/vim_scripts/plugin/cygwin.vim

