
let s:save_cpo = &cpo
set cpo&vim

function! status#Diff()
    set diffopt+=context:1000000

    windo diffthis

    " Disable Folding
    " windo set nofoldenable foldcolumn=0

    " Disable text hiding
    windo set conceallevel=0

    " Reset the cursor the first change in the left window
    wincmd t

    norm! gg]c
endfunction

function! status#HgOpen(line)
    " Must be single quotes in the patterns
    let groups = matchlist(a:line, '\v([MAR?])\s+([^ 	]*)')

    " let groups = matchlist(a:line, '\v(.+)')
    if len(l:groups) == 0
        echom "Invalid line: ".a:line
        return
    endif

    let type = l:groups[1]
    let filename = l:groups[2]

    tabnew

    execute "e! ".l:filename
endfunction

function! status#HGDiff(line)
    " Must be single quotes in the patterns
    let groups = matchlist(a:line, '\v([MAR?])\s+([^ 	]*)')

    " let groups = matchlist(a:line, '\v(.+)')
    if len(l:groups) == 0
        echom "Invalid line: ".a:line
        return
    endif

    let type = l:groups[1]
    let filename = l:groups[2]

    if l:type == 'M'
        execute "tabedit ".l:filename

        let ft = &filetype

        augroup status_diff_close
            autocmd!
            autocmd BufUnload <buffer> tabclose
        augroup END

        silent! execute 'keepalt rightbelow vnew'
        silent! execute 'read !hg cat -r "p1()" '.l:filename

        " :read dumps the output below the current line - so delete the first line
        " (which will be empty)
        0d

        setlocal buftype=nofile nomodifiable bufhidden=wipe nobuflisted noswapfile

        silent! execute 'setf '.ft

        wincmd h

        call status#Diff()
    endif
endfunction

function! status#GitDiff(line)
    " Must be single quotes in the patterns
    let groups = matchlist(a:line, '\vmodified:\s+([^ 	]*)')

    " let groups = matchlist(a:line, '\v(.+)')
    if len(l:groups) == 0
        echom "Invalid line: ".a:line
        return
    endif

    let filename = l:groups[1]

    execute "tabedit ".l:filename

    let ft = &filetype

    augroup status_diff_close
        autocmd!
        autocmd BufUnload <buffer> tabclose
    augroup END

    silent! execute 'keepalt rightbelow vnew'
    silent! execute 'read !git show HEAD:'.l:filename

    " :read dumps the output below the current line - so delete the first line
    " (which will be empty)
    0d

    setlocal buftype=nofile nomodifiable bufhidden=wipe nobuflisted noswapfile

    silent! execute 'setf '.ft

    wincmd h

    call status#Diff()
endfunction

function! status#HGReloadStatus()
    let lineno = line('.')
    setlocal modifiable

    " ! - Dont' use mappings
    normal! ggdG

    silent read !hg status
    normal! ggdd

    setfiletype hg_status
    setlocal nomodifiable

    let new_lineno = min([l:lineno, line('$')])
    execute "normal! ".new_lineno."G"
endfunction

function! status#GitReloadStatus()
    let lineno = line('.')
    setlocal modifiable

    " ! - Dont' use mappings
    normal! ggdG

    silent read !git status
    normal! ggdd

    setfiletype git_status
    setlocal nomodifiable

    let new_lineno = min([l:lineno, line('$')])
    execute "normal! ".new_lineno."G"
endfunction

function! status#OpenStatus()
    " Change directory to the root of the repository
    let [vcs, root, branch] = vcvars#CVcVars()

    enew
    setlocal buftype=nofile nomodifiable bufhidden=wipe nobuflisted noswapfile bufhidden=delete

    if vcs == 'hg'
        call status#HGReloadStatus()

        nmap <silent> <buffer> d :call status#HGDiff(getline("."))<cr>
        nmap <silent> <buffer> r :call status#HGReloadStatus()<cr>
        nmap <silent> <buffer> o :call status#HgOpen(getline("."))<cr>
    endif

    if vcs == 'git'
        call status#GitReloadStatus()

        nmap <silent> <buffer> d :call status#GitDiff(getline("."))<cr>
        nmap <silent> <buffer> r :call status#GitReloadStatus()<cr>
        nmap <silent> <buffer> o :call status#GitOpen(getline("."))<cr>
    endif

    " setlocal readonly
    " setlocal nomodified nomodifiable
endfunction

let &cpo = s:save_cpo
