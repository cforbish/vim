
function! s:GetPid()
    return substitute(system("echo $PPID"), '\n', '', '')
endfunction

function! s:Abs(number)
    let rc = a:number
    if (a:number < 0)
	let rc = -a:number
    endif
    return rc
endfunction

let s:m_w = matchstr(tempname(), '\d\+') * <SID>GetPid()
let s:m_z = localtime()

function! s:RandomNumber(mod)
    let s:m_z = s:m_z + (s:m_z / 4)
    let s:m_w = s:m_w + (s:m_w / 4)
    return <SID>Abs((s:m_z) + s:m_w) % a:mod
endfunction

function! YouIdiot()
    let answer = 2
    while answer == 2
        let answer = confirm('Are you an idiot', "&Yes\n&No", 1)
    endwhile
    echo "\rIt's good you agree you are an idiot."
endfunction

function! Doit()
    for idx in range(100)
	let answer = ""
	for idx in range(5)
	    let answer = answer . printf("%c", 65+<SID>RandomNumber(9))
	endfor
	echo printf("%2d %s", idx, answer)
    endfor
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

