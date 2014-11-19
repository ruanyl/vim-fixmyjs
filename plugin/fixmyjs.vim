"% Preliminary validation of global variables
"  and version of the editor.

if v:version < 700
  finish
endif

" check whether this script is already loaded
if exists('g:loaded_Fixmyjs')
  finish
endif

let g:loaded_Fixmyjs = 1

if !exists('g:config_Fixmyjs')
  let g:config_Fixmyjs = {}
endif

if !exists('g:jshintrc_Fixmyjs')
  let g:jshintrc_Fixmyjs = ''
endif

if !exists('g:use_legacy_Fixmyjs')
    let g:use_legacy_Fixmyjs = 0
endif

" temporary file for content
if !exists('g:tmp_file_Fixmyjs')
  let g:tmp_file_Fixmyjs = fnameescape(tempname().".js")
endif

let s:supportedFileTypes = ['js']

"% Helper functions and variables
let s:plugin_Root_directory = fnamemodify(expand("<sfile>"), ":h")
let s:paths_jshintrc = map(['$HOME/.jshintrc', '$HOME/.vim/.jshintrc', s:plugin_Root_directory.'/.jshintrc'], 'expand(v:val)')

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

  let l:filepath = get(a:000, 0)

  if empty(l:filepath)
    let l:filepath = get(filter(copy(s:paths_jshintrc),'filereadable(v:val)'), 0)
  endif

  if !filereadable(l:filepath)
    " File doesn't exist then return '1'
    call WarningMsg('Can not find global .jshintrc file!')
    return 1
  endif

  let g:jshintrc_Fixmyjs = l:filepath

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
  let winview=winsaveview()
  let cursorPositions = s:getCursorAndMarksPositions()
  call map(cursorPositions, " extend (v:val,{'characters': s:getNumberOfNonSpaceCharactersFromTheStartOfFile(v:val)}) ")


  let path = expand("%:p")
  let path = fnameescape(path)
  let content = getline("1", "$")
  let engine = 'fixmyjs'
  call writefile(content, g:tmp_file_Fixmyjs)

  if executable(engine)
    if g:use_legacy_Fixmyjs == 1
        call system(engine." -l -c ".g:jshintrc_Fixmyjs." ".g:tmp_file_Fixmyjs)
    else
        call system(engine." -c ".g:jshintrc_Fixmyjs." ".g:tmp_file_Fixmyjs)
    endif

    let result = readfile(g:tmp_file_Fixmyjs)
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

" If user doesn't set config_Fixmyjs in
" .vimrc then look up it in .jshintrc
if empty(g:jshintrc_Fixmyjs)
  call FixmyjsApplyConfig(g:jshintrc_Fixmyjs)
endif
command!  Fixmyjs call Fixmyjs()
