

ardinia.b37.ss2120.FAref.impv4.chr${i}.vcf.gz  
Move doinsert:wn with jj to select the columns of text in the lines you want to comment.: at the end:again
nsert:insert: Use Ctrl+V to enter visual block mode: at the end:again
Then hiinsert:t Shift+I and type the text you want to insert.: at the end:again
Then prinsert:ess Escape, the inserted text will appear on all lines.: at the end:again

lua vim.cmd([[
let g:multiline_list = [
            \ 1,
            \ 2,
            \ 3,
            \ ]

echo g:multiline_list
]])


let i = 1
while i < 5
  echo "count is" i
  let i += 1
endwhile


for i in range(1, 7)
  echo "count is" i
endfor


let s:count = 1
if !exists("b:call_count")
  let b:call_count = 0
endif
let b:call_count = b:call_count + 1
echo "called" b:call_count "times"
echo "c*lled" b:c*ll_count "times"

new text new text new text 



function Min(num1, num2)
  if a:num1 < a:num2
    let smaller = a:num1
  else
    let smaller = a:num2
  endif
  return smaller
endfunction



function Count_words() range
  let lnum = a:firstline
  let n = 0
  while lnum <= a:lastline
    let n = n + len(split(getline(lnum)))
    let lnum = lnum + 1
  endwhile
  echo "found " .. n .. " words"
endfunction



function  Number()
  echo "line " .. line(".") .. " contains: " .. getline(".")
endfunction


let alist = ['one', 'two', 'three']
for n in alist
  echo n
endfor


function uk2nl.translate(line) dict
  return join(map(split(a:line), 'get(self, v:val, "???")'))
endfunction

lua local result = vim.api.nvim_exec(
[[
let s:mytext = 'hello world'

function! s:MyFunction(text)
    echo a:text
endfunction

call s:MyFunction(s:mytext)
]],
true)

lua local result = vim.api.nvim_exec(
[[
let s:mytext = 'hello world'

function! s:MyFunction(text)
    echo a:text
    endfunction

    call s:MyFunction(s:mytext)
    ]],
    true)

dev/sh/misc.shLEPSNEs:



function! b:completion_function(ArgLead, CmdLine, CursorPos) abort
    return join([
        \ 'strawberry',
        \ 'star',
        \ 'stellar',
        \ ], "\n")
endfunction

command! -nargs=1 -complete=custom,b:completion_function Test echo <q-args>
" Typing `:Test st[ae]<Tab>` returns "star" and "stellar"





