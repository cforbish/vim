" <AUTO_VIM_SCRIPT_TAG 1> vi: set ft=vim:
sil! set lz
exec 'r ' . expand('<sfile>')
" setup the '< and '> marks for a range for :g
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal V/^" <AUTO_VIM_SCRIPT_TAG 3V
'<,'>g;\<fff\>;s;;\=expand("%:t:r");g
'<,'>g;\<eee\>;s;;\=expand("%:e");g
'<,'>g;\<yyyy\>;s;;\=strftime("%Y");g
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
/* $Id: $ */
/* VI settings: */
/* vi:set ts=3 sts=3 sw=3: */
/*****************************************************************************
*
*             Copyright, Lexmark International, Inc.  1991-yyyy
*             All Rights Reserved.  Proprietary and Confidential.
*
*  FILE
*       fff.eee
*
*  DESCRIPTION
*       TODO give me a description
*
* Modified:
* mm/dd/yy Forbish  Created.
*******************************************************************************/

" <AUTO_VIM_SCRIPT_TAG 3>
