
" use: Replace black cyan
com! -range -nargs=+ Replace call Replace(<f-args>)
com! -nargs=0 SwapRemove call SwapRemove()
com! -nargs=1 Ifndef normal o#ifndef _<args>_H_#define _<args>_H_#endif /* _<args>_H_ */
com! -nargs=0 Date call Date()

com! -nargs=0 ClassInp source ~/vim_scripts/templates/classinp.cpp
com! -nargs=1 ClassArg call ClassArg(<f-args>)

com! -nargs=1 GrepList call GrepList(<f-args>)
com! -nargs=1 GrepIter call GrepIter(<f-args>)

com! -nargs=0 BashShell call BashShell()
com! -nargs=0 WinShell call WinShell()

