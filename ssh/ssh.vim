
let $SSH_ENV="$HOME/.ssh/environment"

" eval file meant for bash as vim commands
function! s:EvalEnvironmentFile()
    let lz=&lz
    new
    exec 'r ' . expand($SSH_ENV)
    sil! v;^\a;d
    sil! %s;\;.*;;g
    sil! %s;\(.*\)=\(.*\);let $\1="\2";g
    let lineno = 1
    while lineno <= line("$")
        exec getline(lineno)
        let lineno = lineno + 1
    endwhile
    sil! bw!
    let &lz=lz
endfunction

" start the ssh-agent
function! s:StartAgent()
    echo "Initializing new SSH agent..."
    let lz=&lz
    new
    sil! set ff=unix
    sil! r !ssh-agent
    sil! %s;^echo;#echo;g
    sil! g;^\s*$;d
    sil! exec 'w ' . $SSH_ENV
    bw!
    let &lz=lz
    call <SID>EvalEnvironmentFile()
    call system("ssh-add")
endfunction

" test for identities
function! s:TestIdentities()
    " test whether standard identities have been added to the agent already
    if match(system('ssh-add -l'), "The agent has no identities") >= 0
        let stat=system("ssh-add")
        " $SSH_AUTH_SOCK broken so we start a new proper agent
        if v:shell_error == 2
            call <SID>StartAgent()
        endif
    endif
endfunction

" check for running ssh-agent with proper $SSH_AGENT_PID
function! InitSsh()
    if strlen($SSH_AGENT_PID) <= 0
        if filereadable(expand($SSH_ENV))
            call <SID>EvalEnvironmentFile()
        endif
    endif
    if match(system("ps -ef"), $SSH_AGENT_PID . ".*ssh-agent") >= 0
        call <SID>TestIdentities()
    else
        call <SID>StartAgent()
    endif
endfunction

