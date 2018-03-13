"% Preliminary validation of global variables
"  and version of the editor.

if v:version < 700
  finish
endif

" check whether this script is already loaded
if exists('g:fixmyjs_loaded')
  finish
endif

let g:fixmyjs_loaded = 1

" Function for debugging
" @param {Any} content Any type which will be converted
" to string and write to tmp file
func! s:console(content)
  let log_dir = fnameescape('/tmp/vimlog')
  call writefile([string(a:content)], log_dir)
  return 1
endfun

" Output warning message
" @param {Any} message The warning message
fun! WarningMsg(message)
  echohl WarningMsg
  echo string(a:message)
endfun

" Output error message
" @param {Any} message The error message
fun! ErrorMsg(message)
  echoerr string(a:message)
endfun

if !exists('g:fixmyjs_legacy_jshint')
    let g:fixmyjs_legacy_jshint = 0
endif

if !exists('g:fixmyjs_engine')
    let g:fixmyjs_engine = 'eslint'
endif

let s:project_root_path = substitute(system("git rev-parse --show-toplevel"), '\n\+$', '', '')
if !isdirectory(s:project_root_path)
  let s:project_root_path = getcwd()
endif

func! s:find_executable()
  let l:executable = g:fixmyjs_engine
  let g:fixmyjs_node_modules = finddir('node_modules', '.;')

  if !empty(g:fixmyjs_node_modules)
    let l:executable = getcwd() . '/' . g:fixmyjs_node_modules . '/.bin/' . g:fixmyjs_engine
  endif

  if !filereadable(l:executable)
    let l:executable = s:project_root_path . '/node_modules/.bin/' . g:fixmyjs_engine
  endif

  if !filereadable(l:executable)
    " fall back to global if we can't find anything
    let l:executable = g:fixmyjs_engine
  endif

  return l:executable
endfun

func! Fixmyjs(...)
  let l:executable = s:find_executable()
  let winview = winsaveview()
  let path = expand("%:p")
  let path = fnameescape(path)

  if executable(l:executable)
    if g:fixmyjs_engine == 'fixmyjs'
      if g:fixmyjs_legacy_jshint == 1
          call system(l:executable." -l ".path)
      else
          call system(l:executable." ".path)
      endif
    elseif g:fixmyjs_engine == 'eslint'
      call system(l:executable." --fix ".path)
    elseif g:fixmyjs_engine == 'jscs'
      call system(l:executable." --fix ".path)
    elseif g:fixmyjs_engine == 'tslint'
      call system(l:executable." --fix ".path)
    endif
    silent exec "e"
  else
    " Executable bin doesn't exist
    call ErrorMsg('The '.g:fixmyjs_engine.' is not executable!')
    return 1
  endif

  call winrestview(winview)

endfun

command!  Fixmyjs call Fixmyjs()
