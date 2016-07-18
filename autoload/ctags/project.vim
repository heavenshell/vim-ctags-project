" File: ctags/project.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" Version:  0.1.1
" WebPage:  http://github.com/heavenshell/vim-ctags-project/
" Description: Generate ctags by each project
" License: BSD, see LICENSE for more details.
if exists('g:ctags_project_loaded')
  finish
endif
let g:ctags_project_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

let s:ext = expand('%:e')

if !exists('g:ctags_project_root_files')
  let g:ctags_project_root_files = []
endif

if !exists('g:ctags_project_root_filetype')
  let g:ctags_project_root_filetype = {}
endif

if !exists('g:ctags_project_bin')
  let g:ctags_project_bin = 'ctags'
endif

" ctags saved path.
if !exists('g:ctags_project_save_path')
  let g:ctags_project_save_path = '~/.vim/tags/' . s:ext . '/'
endif
let g:ctags_project_save_path = expand(g:ctags_project_save_path, ':p')

" Create directory if not exists.
function! s:ensure_directory(filepath)
  if !isdirectory(a:filepath)
    call mkdir(a:filepath, 'p')
  endif
endfunction

" Execute ctags by `job`.
function! s:create_ctags(projectpath, savepath) abort
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif

  if executable('ctags')
    let _ft = s:current_filetype()
    let cmd = printf('%s -R --language-force=%s -f %s %s', g:ctags_project_bin, _ft, a:savepath, a:projectpath)
    let s:job = job_start(cmd, {'out_cb': 'CallbackHandler'})
  redraw | echo 'Update ctags...'
  endif
endfunction

function! CallbackHandler(channel, msg)
  redraw | echo 'Update ctags...done.'
endfunction

function! s:current_filetype()
  let _ft = &filetype
  if has_key(g:ctags_project_root_filetype, _ft)
    return g:ctags_project_root_filetype(_ft)
  endif
  return _ft
endfunction

function! s:detect_project_root(srcpath, filetype) abort
  let files = g:ctags_project_root_files
  if !has_key(files, a:filetype)
    return ''
  endif

  let project_root = ''
  for f in files[a:filetype]
    let project_root = findfile(f, a:srcpath . ';')
    if project_root != ''
      break
    endif
  endfor
  if project_root == ''
    return ''
  endif
  return fnamemodify(project_root, ':p')
endfunction

function! s:savepath() abort
  let project_root = s:detect_project_root(expand('%:p'), s:ext)
  if project_root == ''
    return ''
  endif
  let project_root_name = fnamemodify(project_root, ':h:t:r')
  let project_root_path = fnamemodify(project_root, ':h:p')
  let savepath = g:ctags_project_save_path . project_root_name

  return savepath
endfunction

function! ctags#project#run() abort
  let savepath = s:savepath()

  call s:ensure_directory(savepath)
  call s:create_ctags(project_root_path, savepath . '/tags')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
