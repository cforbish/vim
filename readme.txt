
A list of the original files added to the git repository is in the orgfiles.txt file.

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
