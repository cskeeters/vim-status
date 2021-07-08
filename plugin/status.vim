if exists("loaded_status")
    finish
endif
let loaded_status = 1

let s:save_cpoptions = &cpoptions
set cpoptions&vim

noremap <unique> <script> <Plug>OpenStatus <SID>OpenStatus
noremap <SID>OpenStatus :call status#OpenStatus()<cr>
noremenu <script> Plugin.OpenStatus <SID>OpenStatus
command! -nargs=0 OpenStatus call status#OpenStatus()

let &cpoptions = s:save_cpoptions
unlet s:save_cpoptions
