" vi:set ts=3 sts=3 sw=3 ft=vim et:

if (has("gui_running"))
   if (&background == "dark")
      set background=light
   else
      set background=dark
   endif
   source $HOME/vim/color.vim
   set background ?
endif

