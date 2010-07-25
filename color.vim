" vi:set ts=3 sts=3 sw=3 ft=vim et:

"***************************************************
" Set colors for vim:
"***************************************************

if (has("gui_win32"))
   if (&background == "light")
      colorscheme default
   else
      colorscheme koehler
      " colorscheme elflord
   endif
   syntax  on
endif

