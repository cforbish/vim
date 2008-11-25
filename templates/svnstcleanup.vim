set lz
sil! g;^[\!\~?];d
sil! g;^A  +   ;s;;;g
sil! g;^.\s\+;s;;;g
%!xargs file | grep -v "symbolic link" | sed 's/:.*//'
set nolz
