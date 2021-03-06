filetype plugin indent on
runtime! plugin/**/*.vim

function! s:test(from, to)
  edit `=a:from[0]`
  call cursor(a:from[1], a:from[2])
  Expect [expand('%'), line('.'), col('.')] ==# a:from

  if a:from[0] =~# '\.php$'
    Expect &l:filetype ==# 'php'
    Expect exists('b:tag_user_guess') to_be_true
  else
    Expect &l:filetype !=# 'php'
    Expect exists('b:tag_user_guess') to_be_false
  endif

  execute 'normal' "\<C-]>"
  Expect [a:from, '==>', [expand('%'), line('.'), col('.')]] ==# [a:from, '==>', a:to]
endfunction

describe '<C-]>'
  context 'not in a PHP file'
    it 'behaves the same as the default <C-]>'
      call s:test(['t/fixtures/doc.md', 2, 6], ['t/fixtures/aaa.php', 5, 1])
    end
  end

  context 'in a PHP file'
    it 'jumps to the method of a proper class'
      call s:test(['t/fixtures/aaa.php',  7, 14], ['t/fixtures/aaa.php', 5, 1])
      call s:test(['t/fixtures/aaa.php',  8, 14], ['t/fixtures/bbb.php', 5, 1])
      call s:test(['t/fixtures/aaa.php',  9, 14], ['t/fixtures/ccc.php', 5, 1])
      call s:test(['t/fixtures/aaa.php', 10, 15], ['t/fixtures/aaa.php', 5, 1])
      call s:test(['t/fixtures/aaa.php', 11, 16], ['t/fixtures/aaa.php', 5, 1])

      call s:test(['t/fixtures/bbb.php',  7, 14], ['t/fixtures/aaa.php', 5, 1])
      call s:test(['t/fixtures/bbb.php',  8, 14], ['t/fixtures/bbb.php', 5, 1])
      call s:test(['t/fixtures/bbb.php',  9, 14], ['t/fixtures/ccc.php', 5, 1])
      call s:test(['t/fixtures/bbb.php', 10, 15], ['t/fixtures/bbb.php', 5, 1])
      call s:test(['t/fixtures/bbb.php', 11, 16], ['t/fixtures/bbb.php', 5, 1])

      call s:test(['t/fixtures/ccc.php',  7, 14], ['t/fixtures/aaa.php', 5, 1])
      call s:test(['t/fixtures/ccc.php',  8, 14], ['t/fixtures/bbb.php', 5, 1])
      call s:test(['t/fixtures/ccc.php',  9, 14], ['t/fixtures/ccc.php', 5, 1])
      call s:test(['t/fixtures/ccc.php', 10, 15], ['t/fixtures/ccc.php', 5, 1])
      call s:test(['t/fixtures/ccc.php', 11, 16], ['t/fixtures/ccc.php', 5, 1])
    end

    it 'jumps to a proper method even if the cursor is at non-method part'
      " At class name
      call s:test(['t/fixtures/ccc.php',  8,  9], ['t/fixtures/bbb.php', 5, 1])

      " At ::
      call s:test(['t/fixtures/ccc.php',  8, 12], ['t/fixtures/bbb.php', 5, 1])

      " At self
      call s:test(['t/fixtures/ccc.php', 10, 12], ['t/fixtures/ccc.php', 5, 1])

      " At $this
      call s:test(['t/fixtures/ccc.php', 11,  9], ['t/fixtures/ccc.php', 5, 1])
      call s:test(['t/fixtures/ccc.php', 11, 12], ['t/fixtures/ccc.php', 5, 1])

      " At -> of $this->
      call s:test(['t/fixtures/ccc.php', 11, 15], ['t/fixtures/ccc.php', 5, 1])
    end

    it 'does not jump if the definition is not found'
      let v:errmsg = ''
      call s:test(['t/fixtures/ccc.php', 14, 19], ['t/fixtures/ccc.php', 14, 19])
      Expect v:errmsg ==# 'E426: tag not found: function'
      Expect tag#php#guess() ==# [0, 0]

      let v:errmsg = ''
      call s:test(['t/fixtures/ccc.php', 20, 13], ['t/fixtures/ccc.php', 20, 13])
      Expect v:errmsg ==# 'E426: tag not found: php'
      Expect tag#php#guess() ==# [0, 0]
    end
  end
end
