" <AUTO_VIM_SCRIPT_TAG 1> vi: set ft=vim:
sil! set lz
exec 'r ' . expand('<sfile>')
" setup the '< and '> marks for a range for :g
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal V/^" <AUTO_VIM_SCRIPT_TAG 3V
'<,'>g;\<fff\>;s;;\=expand("%:t:r");g
'<,'>g;\<eee\>;s;;\=expand("%:e");g
'<,'>g;\<yyyy/mm/dd\>;s;;\=strftime("%Y/%m/%d");g
'<,'>g;\<yyyy\>;s;;\=strftime("%Y");g
'<,'>g;\<uuu\>;s;;\=$USER;g
'<,'>g;\<tt:tt:tt\>;s;;\=strftime("%X");g
'<,'>g;\<mm/dd/yy\>;s;;\=strftime("%m/%d/%y");g
" remove all between and including tags 1 and 2
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 1
sil! normal d/^" <AUTO_VIM_SCRIPT_TAG 2dd
" remove first line
sil! normal kdd
" remove tag line 3
sil! normal /^" <AUTO_VIM_SCRIPT_TAG 3dd
?TODO
sil! set nolz
finish
" <AUTO_VIM_SCRIPT_TAG 2>
#!/bin/sh -- # -*-perl-*-
eval '(exit $?0)' && eval 'exec ${BLD_BTOOLS}/bin/bld_perl $0 ${1+"$@"}'
  if 0;
# vi:set ft=perl:
# $Id: $
################################################################################
#
# File : fff.eee
#
# Description: TODO give me a description
#
# Modified:
# mm/dd/yy Forbish  Created.
################################################################################

use strict;
use FindBin;
use lib "$FindBin::Bin";

#--------------------------------------------------------
# To get dumper format of objects used by this script,
# create the directory that $debugdir is initialized to.
#--------------------------------------------------------
my $debugdir = "$ENV{HOME}/debugscripts";
use Data::Dumper;

sub main
{
}

main;

" <AUTO_VIM_SCRIPT_TAG 3>
