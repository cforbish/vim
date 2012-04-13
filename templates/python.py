sil! exec 'r ' . expand('<sfile>')
sil! exec '!chmod +x ' . expand('%')
sil! normal k7dd
sil! update
finish

#!/usr/bin/python
# vi: set ts=8 sw=4 sts=4 et:

def main():
    print "Hello World."

if ( __name__ == "__main__"):
    main()

