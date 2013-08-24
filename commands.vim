
" use: Replace black cyan
com! -range -nargs=+ Replace call Replace(<f-args>)
com! -nargs=0 SwapRemove call SwapRemove()
com! -nargs=1 Ifndef call Ifndef(<f-args>)
com! -nargs=0 ExternC call ExternC()
com! -nargs=0 Date call Date()

com! -nargs=0 ClassInp source ~/vim/templates/classinp.cpp
com! -nargs=1 ClassArg call ClassArg(<f-args>)

com! -nargs=1 GrepList call GrepList(<f-args>)
com! -nargs=1 GrepIter call GrepIter(<f-args>)

com! -nargs=0 BashShell call BashShell()
com! -nargs=0 WinShell call WinShell()

com! -nargs=1 -complete=option TB call ToggleBoolean(<f-args>)

