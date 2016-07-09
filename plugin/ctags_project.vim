" File: ctags/project.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" Version:  0.1.1
" WebPage:  http://github.com/heavenshell/vim-ctags-project/
" Description: Generate ctags by each project
" License: BSD, see LICENSE for more details.
let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 -buffer CtagsProject call ctags#project#run()

nnoremap <silent> <buffer> <Plug>(ctagsProject) :call ctags#project#run()<CR>

let &cpo = s:save_cpo
unlet s:save_cpo
