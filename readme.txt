# vi:set ts=3 sts=3 sw=3 et:

A list of the original files added to the git repository is in the orgfiles.txt file.

#-------------------------------------------------------------------------------
# bitbucket.org
#-------------------------------------------------------------------------------
# Original push
git remote add origin https://cforbish@bitbucket.org/cforbish/vim.git
git push -u origin master
# Clone
git clone https://cforbish@bitbucket.org/cforbish/vim.git

#-------------------------------------------------------------------------------
# I am trying to get windows to not have output out side the vim window.
# found:
# http://vim.wikia.com/wiki/Vim_windows_displaying_output_inside_vim_window
#-------------------------------------------------------------------------------
using system works for now:
echo system("ls -ls")

#-------------------------------------------------------------------------------
# Something else I found (still seems to launch a new window):
# http://vim.wikia.com/wiki/Use_cygwin_shell
#-------------------------------------------------------------------------------
set shell=C:/cygwin/bin/bash
set shellcmdflag=--login\ -c
set shellxquote=\"

#-------------------------------------------------------------------------------
# Using cmd.exe
#-------------------------------------------------------------------------------
set shell=C:\WINDOWS\system32\cmd.exe
set shellcmdflag=/c
set shellxquote=

#-------------------------------------------------------------------------------
# Using rundll32.exe
# This did not work
#-------------------------------------------------------------------------------
set shell=C:\WINDOWS\system32\rundll32.exe

#-------------------------------------------------------------------------------
# http://vim.wikia.com/wiki/Best_Vim_Tips
#-------------------------------------------------------------------------------
nmap \hi :update<CR>:!start c:\progra~1\intern~1\iexplore.exe <cWORD><CR>
:g/^/call setreg(0,getline(".")) | if (@0=~#"DTE") && !((@0=~#"STX") || (@0=~#"ETX")) | d | endif
noremap <Up> gk
noremap <Down> gj
vmap s( <Esc>`>a)<Esc>`<i(<Esc>

