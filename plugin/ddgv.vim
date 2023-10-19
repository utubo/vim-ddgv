if exists('g:loaded_vim_ddgv')
  finish
endif
let g:loaded_vim_ddgv = 1
let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* DDGV call ddgv#Search(<q-args>, <q-mods>)

let &cpo = s:save_cpo
unlet s:save_cpo

