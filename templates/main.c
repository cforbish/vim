exec 'r ' . expand('<sfile>')
sil! normal 5dd
set makeprg=gcc\ -DCOMPILE_ALONE=1\ -Wall\ -g\ -o\ %:r\ %
finish

#include <stdio.h>

#if COMPILE_ALONE == 1
int main(int argc, char **argv)
{
	return 0;
}
#endif

