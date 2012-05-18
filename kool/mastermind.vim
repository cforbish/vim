
let s:m_w = matchstr(tempname(), '\d\+') * getpid()
let s:m_z = localtime()

function! s:RandomNumber(mod)
  let s:m_z = s:m_z + (s:m_z / 4)
  let s:m_w = s:m_w + (s:m_w / 4)
  return abs((s:m_z) + s:m_w) % a:mod
endfunction

function! YouIdiot()
    let answer = 2
    while answer == 2
        let answer = confirm('Are you an idiot', "&Yes\n&No", 1)
    endwhile
    echo "It's good you agree you are an idiot."
    echo "\n"
endfunction

function! MasterMind(num, end)
    let answer = ""
    for idx in range(a:num)
        let answer = answer . printf("%c", 65+<SID>RandomNumber(a:end))
    endfor
    let alpabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let last = printf("%c", 64+a:end)
    let regex = printf("^[A-%s]\\{%d}$", last, a:num)
    let counter = 0
    while 1
        let counter = counter + 1
        let inpstr = printf("Enter guess %d (%d characters A-%s): ", counter, a:num, last)
        while 1
            let guess = input(inpstr)
            echo "\r" . inpstr . guess
            let guess = substitute(guess, '.*', '\U&\E', '')
            if (strlen(guess) != a:num)
                echo "Wrong number of characters entered."
                continue
            elseif (match(guess, regex) < 0)
                echo "Wrong character entered."
                continue
            endif
            break
        endwhile
        if (guess == answer)
            echo printf("You guessed it in %d trys.", counter)
            break
        endif
        let pcorr = 0
        let ncorr = 0
        for idx in range(a:num)
            if (strpart(answer, idx, 1) == strpart(guess, idx, 1))
                let pcorr = pcorr + 1
            endif
        endfor
        for ldx in range(a:end)
            let gnum = 0
            let anum = 0
            for gdx in range(a:num)
                if (strpart(guess, gdx, 1) == strpart(alpabet, ldx, 1))
                    let gnum = gnum + 1
                endif
                if (strpart(answer, gdx, 1) == strpart(alpabet, ldx, 1))
                    let anum = anum + 1
                endif
            endfor
            let ncorr = ncorr + (anum < gnum ? anum : gnum)
        endfor
        echo printf("%s number %d, position %d", guess, ncorr, pcorr)
    endwhile
endfunction

