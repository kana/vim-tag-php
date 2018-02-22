" tag-php - tag-user plugin for PHP
" Version: 0.0.0
" Copyright (C) 2018 Kana Natsuno <https://whileimautomaton.net/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1

function! tag#php#guess()
  let class_name = s:guess_class_name()
  if class_name == ''
    return [0, 0]
  endif

  let tags = taglist(expand('<cword>'), expand('%'))
  for tag in tags
    if has_key(tag, 'class') && tag.class ==# class_name
      return [index(tags, tag) + 1, 0]
    endif
  endfor

  return [0, 0]
endfunction

" Utilities  "{{{1

function! s:guess_class_name()
  let cursor_pos = getpos('.')
  let class_name = s:_guess_class_name()
  call setpos('.', cursor_pos)
  return class_name
endfunction

function! s:_guess_class_name()
  let line = getline('.')
  let prefix_end_index = s:_get_cword_start_pos()[1] - 2
  let prefix = prefix_end_index >= 0 ? line[:prefix_end_index] : ''

  if prefix =~# '\<self::$' || prefix =~# '$this->$'
    return s:_get_current_class_name()
  elseif prefix =~# '\<\k\+::$'
    return matchstr(prefix, '\<\zs\k\+\ze::$')
  else
    return ''
  endif
endfunction

function! s:_get_cword_start_pos()
  let cword = expand('<cword>')
  let cword_pattern = '\V' . escape(cword, '\')
  let cword_end_pos = searchpos(cword_pattern, 'ceW', line('.'))
  let cword_start_pos = searchpos(cword_pattern, 'bcW', line('.'))
  return cword_start_pos
endfunction

function! s:_get_current_class_name()
  normal! 999[{
  if search('\<class\>', 'bW') == 0
    return ''
  endif
  normal! W
  return expand('<cword>')
endfunction

" __END__  "{{{1
" vim: foldmethod=marker
