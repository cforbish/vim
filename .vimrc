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
   if (0 && filereadable('C:\cygwin\bin\bash.exe'))
      " This under evaluation
      set shell=C:/cygwin/bin/bash
      set shellcmdflag=-c
      set shellxquote=\"
      set grepprg=findstr\ /n
   else
      set shell=C:\Windows\system32\cmd.exe
      set shellcmdflag=/c
      set shellxquote=""
      set grepprg=findstr\ /n\ /s
   endif
   set includeexpr=AdjustPath(v:fname)
endif

source $HOME/vim/settings.vim
source $HOME/vim/mappings.vim
source $HOME/vim/commands.vim
source $HOME/vim/function.vim
source $HOME/vim/color.vim
source $HOME/vim/man.vim
source $HOME/vim/tlist.vim
source $HOME/vim/plugin/lxkcommand.vim
source $HOME/vim/plugin/cygwin.vim
source $HOME/vim/kool/mastermind.vim
source $HOME/vim/ssh/ssh.vim

