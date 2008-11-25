exe 'r ' . expand("<sfile>")
sil! normal 5dd
set makeprg=g++\ -DCOMPILE_ALONE=1\ -Wall\ -g\ -o\ %:r\ %
finish

#include <iostream>

using namespace std;

#if COMPILE_ALONE == 1
int main(int argc, char **argv)
{
	return 0;
}
#endif

