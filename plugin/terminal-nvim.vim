if !has('nvim-0.5')
    echoerr "Terminal.nvim requires at least Neovim 0.5. Please upgrade or uninstall."
    finish
endif

if exists('g:loaded_terminal')
    finish
endif
let g:loaded_terminal = v:true

