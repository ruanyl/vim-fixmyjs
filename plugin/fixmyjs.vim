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

if !exists('g:fixmyjs_config')
  let g:fixmyjs_config = {}
endif

if !exists('g:fixmyjs_rc_path')
  let g:fixmyjs_rc_path = ''
endif

if !exists('g:fixmyjs_legacy_jshint')
    let g:fixmyjs_legacy_jshint = 0
endif

if !exists('g:fixmyjs_engine')
    let g:fixmyjs_engine = 'eslint'
endif

if g:fixmyjs_engine == 'eslint'
    let g:fixmyjs_rc_filename = '.eslintrc'
elseif g:fixmyjs_engine == 'fixmyjs'
    let g:fixmyjs_rc_filename = '.jshintrc'
elseif g:fixmyjs_engine == 'jscs'
    let g:fixmyjs_rc_filename = '.jscsrc'
endif

" temporary file for content
if !exists('g:fixmyjs_tmp_file')
  let g:fixmyjs_tmp_file = fnameescape(tempname().".js")
endif

let s:supportedFileTypes = ['js']

"% Helper functions and variables
let s:plugin_Root_directory = fnamemodify(expand("<sfile>"), ":h")
let s:rc_paths = map(['$HOME/'.g:fixmyjs_rc_filename, '$HOME/.vim/'.g:fixmyjs_rc_filename], 'expand(v:val)')

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


" Quoting string
" @param {String} str Any string
" @return {String} The quoted string
func! s:quote(str)
  return '"'.escape(a:str,'"').'"'
endfun


" Helper functions for restoring mark and cursor position
function! s:getNumberOfNonSpaceCharactersFromTheStartOfFile(position)
  let cursorRow = a:position.line
  let cursorColumn = a:position.column
  let lineNumber = 1
  let nonBlankCount = 0
  while lineNumber <= cursorRow
    let lineContent = getline(lineNumber)
    if lineNumber == cursorRow
      let lineContent = strpart(lineContent,0,cursorColumn)
    endif
    let charIndex = 0
    while charIndex < len(lineContent)
      let char = strpart(lineContent,charIndex,1)
      if match(char,'\s\|\n\|\r') == -1
        let nonBlankCount = nonBlankCount + 1
      endif
      let charIndex = charIndex + 1
    endwhile
    "echo nonBlankCount
    let lineNumber = lineNumber + 1
  endwhile
  return nonBlankCount
endfunction



"Converts number of non blank characters to cursor position (line and column)
function! s:getCursorPosition(numberOfNonBlankCharactersFromTheStartOfFile)
  let lineNumber = 1
  let nonBlankCount = 0
  while lineNumber <= line('$')
    let lineContent = getline(lineNumber)
    let charIndex = 0
    while charIndex < len(lineContent)
      let char = strpart(lineContent,charIndex,1)
      if match(char,'\s\|\n\|\r') == -1
        let nonBlankCount = nonBlankCount + 1
      endif
      let charIndex = charIndex + 1
      if nonBlankCount == a:numberOfNonBlankCharactersFromTheStartOfFile 
        "Found position!
        return {'line': lineNumber,'column': charIndex}
      end
    endwhile
    let lineNumber = lineNumber + 1
  endwhile

  "Oops, nothing found!
  return {}
endfunction


function! s:getCursorAndMarksPositions()
  let localMarks = map(range(char2nr('a'), char2nr('z'))," \"'\".nr2char(v:val) ") 
  let marks = ['.'] + localMarks
  let result = {}
  for positionType in marks
    let cursorPositionAsList = getpos(positionType)
    let cursorPosition = {'buffer': cursorPositionAsList[0], 'line': cursorPositionAsList[1], 'column': cursorPositionAsList[2]}
    if cursorPosition.buffer == 0 && cursorPosition.line > 0
      let result[positionType] = cursorPosition
    endif
  endfor
  return result
endfunction


"% Declaring global variables and functions

" Apply settings from 'editorconfig' file to fixmyjs
" @param {String} filepath path to configuration 'editorconfig' file.
" @return {Number} If apply was success then return '0' else '1'
function FixmyjsApplyConfig(...)

  let l:filepath = substitute(system("git rev-parse --show-toplevel"), '\n\+$', '', '') . "/" . g:fixmyjs_rc_filename

  if !filereadable(l:filepath)
    let l:filepath = get(filter(copy(s:rc_paths),'filereadable(v:val)'), 0)
  endif

  if !filereadable(l:filepath)
    " File doesn't exist then return '1'
    call WarningMsg('Can not find global .jshintrc file!')
    return 1
  endif

  let g:fixmyjs_rc_path = l:filepath

  " All Ok! return '0'
  return 0
endfunction


" Common function for fixmyjs
" @param {String} type The type of file js, css, html
" @param {[String]} line1 The start line from which will start
" formating text, by default '1'
" @param {[String]} line2 The end line on which stop formating,
" by default '$'
func! Fixmyjs(...)
  " If user doesn't set fixmyjs_config in
  " .vimrc then look up it in .jshintrc
  if empty(g:fixmyjs_rc_path)
    call FixmyjsApplyConfig()
  endif

  let winview=winsaveview()
  let cursorPositions = s:getCursorAndMarksPositions()
  call map(cursorPositions, " extend (v:val,{'characters': s:getNumberOfNonSpaceCharactersFromTheStartOfFile(v:val)}) ")


  let path = expand("%:p")
  let path = fnameescape(path)
  let content = getline("1", "$")
  "let engine = 'fixmyjs'
  call writefile(content, g:fixmyjs_tmp_file)

  if executable(g:fixmyjs_engine)
    if g:fixmyjs_engine == 'fixmyjs'
      if g:fixmyjs_legacy_jshint == 1
          call system(g:fixmyjs_engine." -l -c ".g:fixmyjs_rc_path." ".g:fixmyjs_tmp_file)
      else
          call system(g:fixmyjs_engine." -c ".g:fixmyjs_rc_path." ".g:fixmyjs_tmp_file)
      endif
    elseif g:fixmyjs_engine == 'eslint'
      call system(g:fixmyjs_engine." -c ".g:fixmyjs_rc_path." --fix ".g:fixmyjs_tmp_file)
    elseif g:fixmyjs_engine == 'jscs'
      call system(g:fixmyjs_engine." -c ".g:fixmyjs_rc_path." --fix ".g:fixmyjs_tmp_file)
    endif

    let result = readfile(g:fixmyjs_tmp_file)
    "call writefile(result, path)
    silent exec "1,$j"
    call setline("1", result[0])
    call append("1", result[1:])
  else
    " Executable bin doesn't exist
    call ErrorMsg('The '.engine.' is not executable!')
    return 1
  endif

  call winrestview(winview)

endfun

command!  Fixmyjs call Fixmyjs()
