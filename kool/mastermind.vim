
let s:m_w = matchstr(tempname(), '\d\+') * getpid()
let s:m_z = localtime()
 
function! s:RandomNumber(mod)
  let s:m_z = s:m_z + (s:m_z / 4)
  let s:m_w = s:m_w + (s:m_w / 4)
  return abs((s:m_z) + s:m_w) % a:mod
endfunction

command! -nargs=? RandomNumber :call <SID>RandomNumber(<q-args>)

function! Doit()
    let val=<SID>RandomNumber(7)
    echo "val: " . val
endfunction

call Doit()
call Doit()
call Doit()
call Doit()
call Doit()
call Doit()
call Doit()
call Doit()
call Doit()

