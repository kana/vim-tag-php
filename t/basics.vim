filetype plugin indent on
runtime! plugin/**/*.vim

describe '<C-]>'
  context 'not in a PHP file'
    it 'behaves the same as the default <C-]>'
      TODO
    end
  end

  context 'in a PHP file'
    it 'jumps to the method of a proper class'
      TODO
    end

    it 'jumps to the method of a proper class even if the cursor is at class'
      TODO
    end
  end
end
