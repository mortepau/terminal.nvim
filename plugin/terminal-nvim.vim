if !has('nvim-0.5')
    echoerr "Terminal.nvim requires at least Neovim 0.5. Please upgrade or uninstall."
    finish
endif

if exists('g:loaded_terminal')
    finish
endif
let g:loaded_terminal = v:true

function! s:list(bang) abort
    call luaeval('require("terminal.api").list_show(_A)', a:bang)
endfunction

function! s:named_completion(...)
    return luaeval('require("terminal.api").named_completion(_A)', a:000)
endfunction

function! s:positional_completion(...)
    return luaeval('require("terminal.api").positional_completion(_A)', a:000)
endfunction

function! s:named_call(command, ...)
    call luaeval('require("terminal.api").named_call(_A)', [a:command, a:000])
endfunction

function! s:positional_call(command, ...)
    call luaeval('require("terminal.api").positional_call(_A)', [a:command, a:000])
endfunction

augroup TerminalNvim
    autocmd! BufEnter * lua require('terminal.manager').update_last(true)
    autocmd! BufLeave * lua require('terminal.manager').update_last(false)
augroup END

command! -nargs=* -complete=customlist,s:named_completion Terminal call s:named_call('open', <f-args>)
command! -nargs=* -complete=customlist,s:named_completion TermOpen call s:named_call('open', <f-args>)
command! -nargs=* -complete=customlist,s:named_completion TermToggle call s:named_call('toggle', <f-args>)
command! -nargs=* -complete=customlist,s:positional_completion TermClose call s:positional_call('close', <f-args>)
command! -nargs=+ -complete=customlist,s:positional_completion TermMove call s:positional_call('move', <f-args>)
command! -nargs=+ -complete=customlist,s:positional_completion TermEcho call s:positional_call('echo', <f-args>)
command! -nargs=* -complete=customlist,s:positional_completion TermExit call s:positional_call('exit', <f-args>)
command! -nargs=0 -bang TermList call s:list(<bang>0)
