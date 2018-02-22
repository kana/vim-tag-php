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
  let context = s:parse_context()
  if context is 0
    return [0, 0]
  endif
  let [class_name, method_name] = context

  let tags = taglist(method_name, expand('%'))
  for tag in tags
    if has_key(tag, 'class') && tag.class ==# class_name
      return [index(tags, tag) + 1, method_name]
    endif
  endfor

  return [0, 0]
endfunction

" Utilities  "{{{1

function! s:parse_context()
  let cursor_pos = getpos('.')
  let result = s:_parse_context()
  call setpos('.', cursor_pos)
  return result
endfunction

function! s:_parse_context()
  " --------------------------------------------------------------------------
  " | # | Situation           | prefix      | <cword>     | suffix           |
  " |---|---------------------|-------------|-------------|------------------|
  " | 1 | Foo::doSomething(); |             | Foo         | ::doSomething(); |
  " |---|---^-----------------|-------------|-------------|------------------|
  " | 2 | Foo::doSomething(); | Foo::       | doSomething | ();              |
  " |---|----^----------------|-------------|-------------|------------------|
  " | 3 | Foo::doSomething(); | Foo::       | doSomething | ();              |
  " |---|-----^---------------|-------------|-------------|------------------|
  " | 4 | Foo::doSomething(); | Foo::       | doSomething | ();              |
  " |---|------^--------------|-------------|-------------|------------------|
  " | 5 | Foo::doSomething(); | doSomething | ();         |                  |
  " ----------------------^---------------------------------------------------
  "
  " (`^` denotes the cursor position.)
  "
  " Because of #2 and #3, cword_end_col must be searched first,
  " and this search must move the cursor.

  let line = getline('.')
  let cword = expand('<cword>')
  if cword !~# '^\k\+$'
    " Do nothing for non-identifier cword.
    return 0
  endif

  let cword_pattern = '\V' . escape(cword, '\')
  let [_, cword_end_col] = searchpos(cword_pattern, 'ceW', line('.'))
  let [_, cword_start_col] = searchpos(cword_pattern, 'bcW', line('.'))

  let prefix = line[:cword_start_col - 2]
  let suffix = line[cword_end_col:]

  if prefix =~# '\<self::$' || prefix =~# '$this->$'
    return [s:_get_current_class_name(), cword]
  elseif prefix =~# '\<\k\+::$'
    return [matchstr(prefix, '\<\k\+\ze::$'), cword]
  elseif cword ==# 'self' && suffix =~# '^::' || cword ==# 'this' && suffix =~# '^->'
    return [s:_get_current_class_name(), matchstr(suffix, '^\(::\|->\)\zs\k\+')]
  elseif suffix =~# '^::\k\+'
    return [cword, matchstr(suffix, '^::\zs\k\+')]
  else
    " This context is not recognizable.
    return 0
  endif
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
