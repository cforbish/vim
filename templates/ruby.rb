sil! exec 'r ' . expand('<sfile>')
sil! exec '!chmod +x ' . expand('%')
sil! normal k7dd
sil! update
finish

#!/usr/bin/ruby
# vi: set ts=8 sw=4 sts=4 et:

def main()
    print "Hello World."
end

main
 

