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

if !exists('g:fixmyjs_sort_import_on_write')
  let g:fixmyjs_sort_import_on_write = 0
endif

if !exists('g:fixmyjs_config')
  let g:fixmyjs_config = {}
endif

if !exists('g:fixmyjs_rc_path')
  let g:fixmyjs_rc_path = ''
endif

if !exists('g:fixmyjs_rc_local')
  let g:fixmyjs_rc_local = 0
endif

if !exists('g:fixmyjs_legacy_jshint')
    let g:fixmyjs_legacy_jshint = 0
endif

if !exists('g:fixmyjs_engine')
    let g:fixmyjs_engine = 'eslint'
endif

let s:project_root_path = substitute(system("git rev-parse --show-toplevel"), '\n\+$', '', '')

let s:possible_paths = [s:project_root_path, '$HOME', '$HOME/.vim']

if !exists('g:fixmyjs_rc_filename')
  if g:fixmyjs_engine == 'eslint'
      let g:fixmyjs_rc_filename = '.eslintrc'
  elseif g:fixmyjs_engine == 'fixmyjs'
      let g:fixmyjs_rc_filename = '.jshintrc'
  elseif g:fixmyjs_engine == 'jscs'
      let g:fixmyjs_rc_filename = '.jscsrc'
  elseif g:fixmyjs_engine == 'tslint'
      let g:fixmyjs_rc_filename = 'tslint.json'
  endif
endif

" If g:fixmyjs_rc_filename is an array, we replace it with the filename that is found first
" using the list of possible paths
func! s:find_rc_path()
  let s:rc_file_found = 0

  " If specified, try to find the nearest configuration file based on the
  " current file
  if g:fixmyjs_rc_local
    if type(g:fixmyjs_rc_filename) == type([])
      for l:rc_filename in g:fixmyjs_rc_filename
        let l:rc_filename_found = findfile(l:rc_filename, '.;')
        let l:full_path = l:rc_filename_found
        if filereadable(l:full_path)
          let g:fixmyjs_rc_path = l:full_path
          let s:rc_file_found = 1
          break
        endif
      endfor
    else
      let l:rc_filename_found = findfile(g:fixmyjs_rc_filename, '.;')
      let l:full_path = l:rc_filename_found
      if filereadable(l:full_path)
        let g:fixmyjs_rc_path = l:full_path
        let s:rc_file_found = 1
      endif
    endif
    if s:rc_file_found
      return s:rc_file_found
    endif
  endif

  if type(g:fixmyjs_rc_filename) == type([])
    for l:possible_path in s:possible_paths
      for l:rc_filename in g:fixmyjs_rc_filename
        let l:full_path = expand(l:possible_path . '/' . l:rc_filename)
        if filereadable(l:full_path)
          let g:fixmyjs_rc_path = l:full_path
          let s:rc_file_found = 1
          break
        endif
      endfor
      if s:rc_file_found
        break
      endif
    endfor
  else
    for l:possible_path in s:possible_paths
      let l:full_path = l:possible_path . '/' . g:fixmyjs_rc_filename
      if filereadable(l:full_path)
        let g:fixmyjs_rc_path = l:full_path
        let s:rc_file_found = 1
        break
      endif
    endfor
  endif
  return s:rc_file_found
endfun

if !exists('g:fixmyjs_executable')
    let g:fixmyjs_executable = g:fixmyjs_engine
endif

" temporary file for content
if !exists('g:fixmyjs_tmp_file')
  let g:fixmyjs_tmp_file = fnameescape(tempname().".js")
endif

let s:supportedFileTypes = ['js']

"% Helper functions and variables

func! s:find_executable()
  if exists('g:fixmyjs_use_local') && g:fixmyjs_use_local
    let g:fixmyjs_node_modules = finddir('node_modules', '.;')
    if !empty(g:fixmyjs_node_modules)
      let g:fixmyjs_executable = getcwd() . '/' . g:fixmyjs_node_modules . '/.bin/' . g:fixmyjs_engine
    endif
    if !filereadable(g:fixmyjs_executable)
      let g:fixmyjs_executable = s:project_root_path . '/node_modules/.bin/' . g:fixmyjs_engine
    endif
    if !filereadable(g:fixmyjs_executable)
      " fall back to system one if we can't find anything
      let g:fixmyjs_executable = g:fixmyjs_engine
    endif
  endif
endfun

func! Fixmyjs(...)
  call s:find_rc_path()
  if empty(g:fixmyjs_rc_path) || !filereadable(g:fixmyjs_rc_path)
    " File doesn't exist then return '1'
    let l:found = s:find_rc_path()
    if !l:found
      call WarningMsg('Can not find a valid config file for ' . g:fixmyjs_engine)
      return 1
    endif
  endif

  call s:find_executable()

  let winview=winsaveview()
  let path = expand("%:p")
  let path = fnameescape(path)
  let content = getline("1", "$")
  "let engine = 'fixmyjs'
  call writefile(content, g:fixmyjs_tmp_file)

  let g:fixmyjs_executable = expand(g:fixmyjs_executable)
  if executable(g:fixmyjs_executable)
    if g:fixmyjs_engine == 'fixmyjs'
      if g:fixmyjs_legacy_jshint == 1
          call system(g:fixmyjs_executable." -l -c ".g:fixmyjs_rc_path." ".g:fixmyjs_tmp_file)
      else
          call system(g:fixmyjs_executable." -c ".g:fixmyjs_rc_path." ".g:fixmyjs_tmp_file)
      endif
    elseif g:fixmyjs_engine == 'eslint'
      call system(g:fixmyjs_executable." -c ".g:fixmyjs_rc_path." --fix ".g:fixmyjs_tmp_file)
    elseif g:fixmyjs_engine == 'jscs'
      call system(g:fixmyjs_executable." -c ".g:fixmyjs_rc_path." --fix ".g:fixmyjs_tmp_file)
    elseif g:fixmyjs_engine == 'tslint'
      call system(g:fixmyjs_executable." -c ".g:fixmyjs_rc_path." --fix ".g:fixmyjs_tmp_file)
    endif

    let result = readfile(g:fixmyjs_tmp_file)
    "call writefile(result, path)
    silent exec "1,$j"
    call setline("1", result[0])
    call append("1", result[1:])
  else
    " Executable bin doesn't exist
    call ErrorMsg('The '.g:fixmyjs_engine.' is not executable!')
    return 1
  endif

  call winrestview(winview)

endfun

func! SortImport(...)
  let winview=winsaveview()
  let path = expand("%:p")
  let path = fnameescape(path)

  let l:import_sort_executable = s:project_root_path . '/node_modules/.bin/import-sort'
  if !executable(l:import_sort_executable)
    let l:import_sort_executable = 'import-sort'
  endif

  if executable(l:import_sort_executable)
    let l:import_sort_tmp_file = fnameescape(tempname())
    call system(l:import_sort_executable . ' ' . path . ' --write ' . l:import_sort_tmp_file)

    if filereadable(l:import_sort_tmp_file)
      let result = readfile(l:import_sort_tmp_file)
      "call writefile(result, path)
      "silent exec "e"
      silent exec "1,$j"
      call setline("1", result[0])
      call append("1", result[1:])
      silent exec "w"
    endif
  else
    " Executable bin doesn't exist
    call ErrorMsg('Can not find import-sort')
    return 1
  endif
  call winrestview(winview)
endfun

if g:fixmyjs_sort_import_on_write
  augroup fixmyjs
    autocmd! fixmyjs
    " do not do import sort on save in diff mode
    if !&diff
      au BufWritePost *.js,*.jsx,*.es6,*.es,*.ts,*.tsx call SortImport()
    endif
  augroup END
endif

command! Fixmyjs call Fixmyjs()
command! SortImport call SortImport()
