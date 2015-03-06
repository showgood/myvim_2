" -------------------------------
"  wrapper for built-in vimgrep 
"  make it easier to search for more than one extension
" Author: showgood
" -------------------------------
"function MyGrep(pattern, location, filetype)
    "let location = a:location
    "if empty(a:location)
        "let location = getcwd()
        "echom "using working directory"
    "endif

    "exec "lcd ".location
    "let ext = ''
    "if a:filetype ==# 'cpp'
        "let ext = "**/*."."cpp"." **/*."."hpp"
    "elseif a:filetype ==# 'xml'
        "let ext = "**/*."."xml"
    "endif

    "exec "vimgrep ".a:pattern." ".ext
    "exec "lcd -"
"endfunction

"generate a sequence of numbers
"function GenSeq(start, len)
    "for i in range(a:start, a:start + a:len)
        "put = i
    "endfor
"endfunction

"" convert markdown file to html
"function! Markdown2Html()
    "let path_html = g:vimwiki_list[0].path_html
    "let input = expand("%:t:r")
    "let output = path_html.input.'.html'
    "let cmd = "markdown_cmd --html4tags ".expand("%")."| tee ".output
    "call xolox#shell#execute(cmd, 0)
"endfunction

"------------------------------------------------------------------------
"simple wrapper so we can pass argument to TortoiseSvn
" depends on vim-shell plugin
" Author: showgood
"------------------------------------------------------------------------
function! ExecCmd(command)
    let cmd = a:command
    call xolox#misc#os#exec({'command':cmd, 'async': 1})
endfunction

function! ExecuteCommand(command, arg)
    let cmd = a:command
    if a:arg == "%"
        let cmd .= expand("%")
    else
        let cmd .= a:arg
    endif
    echom cmd
    call xolox#misc#os#exec({'command':cmd, 'async': 1})
endfunction

"------------------------------------------------------------------------
"change the current function declaration to implementation
" change something like (normally copied from a hpp file to cpp file):
" virtual void InitialiseIntAttribute(const UIString& name, int value);
" to (suppose the file is MyClass.cpp and cursor is on this line):
" void MyClass::InitialiseIntAttribute(const UIString& name, int value)
"{
"    [cursor here]
"}
"Author: showgood
"------------------------------------------------------------------------
function! Htoc(parts)
    let tmp_parts = substitute(a:parts, "\n", "", "")
    let parts = split(tmp_parts, " ")

    if parts[0] ==# 'virtual'
       call remove(parts, 0)
   endif

    let classPrefix = expand("%:t:r")."::"
    let lastPart = substitute(parts[-1], ';', '', '')
    call insert(parts, classPrefix, 1)
    let parts[-1] = lastPart
    let result = join(parts, ' ')
    let result = substitute(result, ':: ', '::', '')
    call setline('.', result)
    let restPart = ['{', '    ', '}']
    call append('.', restPart)
    call cursor(line('.') + 2, 4)
endf

"return how many active windows there..
"function! GetActiveWindowNumber()
    "let windowNum = 1

    "while winbufnr(windowNum) != -1
        "let windowNum += 1
    "endwhile

    "return windowNum - 1
"endfunction

"------------------------------------------------------------------------
"function which use beyond compare to compare
"two files currently opened in two windows
"must have two windows opened
"the path for beyond compare must be put
"in the PATH environment variable
"Author: showgood
"------------------------------------------------------------------------
function CompareSideBySide()
    if winbufnr(2) == -1
        echo "only one window.."
        return
    endif

    if winbufnr(3) != -1
        echo "more than two windows.."
        return
    endif

    let buf_a  = bufname(winbufnr(1))
    let buf_b  = bufname(winbufnr(2))
    let file_a = fnamemodify(buf_a, ":p")
    let file_b = fnamemodify(buf_b, ":p")

    call CompareTwoFiles(file_a, file_b)
endfunction

function CompareTwoFiles(fileA, fileB)
    let cmd  = "BComp.exe ". a:fileA . " " . a:fileB
    call xolox#shell#execute(cmd, 0)
endfunction

"toggle the quickfix window
"if it's already opened, then close it
"function! ToggleQuickFixWindow()
    "for i in range(1, winnr('$'))
        "let bnum = winbufnr(i)
        "if getbufvar(bnum, '&buftype') == 'quickfix'
            "cclose
            "return
        "endif
    "endfor

    ""make quickfix window always open
    ""in the bottom and span the whole
    ""width of vim window
    "botright copen
"endfunction

"" quickfixopenall.vim
""Author:
""   Tim Dahlin
""
""Description:
""   Opens all the files in the quickfix list for editing.
""
""Usage:
""   1. Perform a vimgrep search
""       :vimgrep /def/ *.rb
""   2. Issue QuickFixOpenAll command
""       :QuickFixOpenAll

"function!   QuickFixOpenAll()
    "if empty(getqflist())
        "return
    "endif
    "let s:prev_val = ""
    "for d in getqflist()
        "let s:curr_val = bufname(d.bufnr)
        "if (s:curr_val != s:prev_val)
            "exec "edit " . s:curr_val
        "endif
        "let s:prev_val = s:curr_val
    "endfor
"endfunction

"command! QuickFixOpenAll call QuickFixOpenAll()

"command! -nargs=0 -bar Qargs execute 'args ' . QuickfixFilenames()

"function! QuickfixFilenames()
  "" Building a hash ensures we get each buffer only once
  "let buffer_numbers = {}
  "for quickfix_item in getqflist()
    "let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
  "endfor
  "return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
"endfunction

"" execute a command on every file in the quickfix list
"" http://stackoverflow.com/questions/5686206/search-replace-using-quickfix-list-in-vim#comment8286582_5686810
"command! -nargs=1 -complete=command -bang Qdo exe 'args '.QuickfixFilenames() | argdo<bang> <args>

"" remove all the entries
""http://stackoverflow.com/questions/15406138/is-it-possible-to-grep-vims-quickfix
"function! GrepQuickFix(pat)
  "let all = getqflist()
  "for d in all
    "if bufname(d['bufnr']) !~ a:pat && d['text'] !~ a:pat
        "call remove(all, index(all,d))
    "endif
  "endfor
  "call setqflist(all)
"endfunction

""remove all the entries matches pattern in the quickfix
"function! FilterQuickFix(pat)
  "let all = getqflist()
  "for d in all
    "if bufname(d['bufnr']) =~ a:pat || d['text'] =~ a:pat
        "call remove(all, index(all,d))
    "endif
  "endfor
  "call setqflist(all)
"endfunction

"command! -nargs=* GQ call GrepQuickFix(<q-args>)
"command! -nargs=* FQ call FilterQuickFix(<q-args>)

"function! StartFolding()
    "setlocal foldmethod=syntax
    "setlocal foldlevelstart=0
    "setlocal foldnestmax=2
    "norm zM
"endfunction

"" SetQuickfixList(list, [action]) {{{
"" Sets the contents of the quickfix list.
"function! WriteToQuickfixList(list, ...)
  "let qflist = a:list
  "if a:0 == 0
    "call setqflist(qflist)
  "else
    "call setqflist(qflist, a:1)
  "endif
  "exec 'botright copen'
"endfunction " }}}

" -------------------------------
"  calculate the number of lines between current line and line marked with mark
" Author: showgood
" -------------------------------
function! GapFromMark(mark)
    let currentLineNo = line(".")
    let markLineNo = line("'" . a:mark)
    let gap = abs(currentLineNo - markLineNo)

    let message = printf("gap between current line(%d) and mark %s [ %s ] is %d", currentLineNo, a:mark, getline("'" . a:mark), gap)
    echom message
endfunction

"function! SetupCScope(path)
   "exec "!/usr/bin/find ". a:path "-iname '*.c' -o -iname '*.cpp' -o -iname '*.h' -o -iname '*.hpp' > cscope.files"

  "exec "!cscope -b -i cscope.files -f cscope.out"
  "cs reset
"endfunction
