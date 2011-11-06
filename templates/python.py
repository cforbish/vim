sil! exec 'r ' . expand('<sfile>')
sil! exec '!chmod +x ' . expand('%')
sil! normal k6dd
finish

#!/usr/bin/python
# vi: set ts=8 sw=3 sts=3 et:

def main():
   print "Hello World."

if ( __name__ == "__main__"):
   main()

