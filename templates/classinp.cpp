" <AUTO_VIM_SCRIPT_TAG 1> vi: set ft=vim:
sil! set lz
exe 'r ' . expand("<sfile>")
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 2
sil! normal V/^" <AUTO_VIM_SCRIPT_TAG 3V
let g:classname=""
let n = inputdialog("Enter class name", g:classname)
if n != ""
  let g:classname = n
endif
echo "g:classname " . g:classname
'<,'>g;\<classname\>;s;;\=g:classname;g
set makeprg=g++\ -DCOMPILE_ALONE=1\ -Wall\ -g\ -o\ %:r\ %
" remove all between and including tags 1 and 2
sil! normal gg/^" <AUTO_VIM_SCRIPT_TAG 1
sil! normal d/^" <AUTO_VIM_SCRIPT_TAG 2dd
" remove tag line 3
sil! normal /^" <AUTO_VIM_SCRIPT_TAG 3dd
sil! set nolz
finish
" <AUTO_VIM_SCRIPT_TAG 2>
class classname
{
	public:
		classname()
		{
		};
		virtual ~classname()
		{
		};
};

// classname::classname()
// {
// }
// 
// classname::~classname()
// {
// }

" <AUTO_VIM_SCRIPT_TAG 3>
