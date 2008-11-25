sil! exec 'r ' . expand('<sfile>')
sil! normal 4dd
finish

CC = g++
COPTIONS = -c -g -Wall
LOPTIONS = -o

NPADIR = npap
PROGRAMS = how are you doing today

all:	main

neat:
	@echo word is $(PROGRAMS:%=$(NPADIR)/%)

clean:
	rm -rf *.o

distclean:	clean
	rm main

remake:	all clean

main:	main.o file1.o file2.o
	$(CC) $(LOPTIONS) main main.o file1.o file2.o

main.o:	main.c file1.h file2.h
	$(CC) $(COPTIONS) main.c

file1.o:	file1.c file1.h
	$(CC) $(COPTIONS) file1.c

file2.o:	file2.c file2.h
	$(CC) $(COPTIONS) file2.c

