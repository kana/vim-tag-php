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
  Expect [expand('%'), line('.'), col('.')] ==# a:to
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

      call s:test(['t/fixtures/bbb.php',  7, 14], ['t/fixtures/aaa.php', 5, 1])
      call s:test(['t/fixtures/bbb.php',  8, 14], ['t/fixtures/bbb.php', 5, 1])
      call s:test(['t/fixtures/bbb.php',  9, 14], ['t/fixtures/ccc.php', 5, 1])
      call s:test(['t/fixtures/bbb.php', 10, 15], ['t/fixtures/bbb.php', 5, 1])

      call s:test(['t/fixtures/ccc.php',  7, 14], ['t/fixtures/aaa.php', 5, 1])
      call s:test(['t/fixtures/ccc.php',  8, 14], ['t/fixtures/bbb.php', 5, 1])
      call s:test(['t/fixtures/ccc.php',  9, 14], ['t/fixtures/ccc.php', 5, 1])
      call s:test(['t/fixtures/ccc.php', 10, 15], ['t/fixtures/ccc.php', 5, 1])
    end

    it 'jumps to the method of a proper class even if the cursor is at class'
      TODO
    end
  end
end
