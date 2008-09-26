
" use: Replace black cyan
com! -range -nargs=+ Replace call Replace(<f-args>)
com! -nargs=0 SwapRemove call SwapRemove()
com! -nargs=1 Ifndef normal o#ifndef _<args>_H_#define _<args>_H_#endif /* _<args>_H_ */
com! -nargs=0 Date call Date()

