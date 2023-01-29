require 'instruction'

class Decoder
  LONGWORD_SIZE = 4
  WORD_SIZE = 2
  BYTE_SIZE = 1
  def get_instruction(memory, pc)
    # According to https://www.nxp.com/files-static/archives/doc/ref_manual/M68000PRM.pdf
    # "instructions consist of at least one word"
    # "The first word of the instruction, called the simple effective address operation word,
    #  specifies the length of the instruction, the effective addressing mode, and the
    #  operation to be performed"
    word = memory.get_word(pc)

    instruction, adv = case word
      when 0x4E71 # NOP
        [Instruction::NOP.new, WORD_SIZE]
      when 0x46FC # move a (16bit) word to status register
        # Here we've matched entire long word but if you only match the upper word,
        # you'd need something like `if (next_word & 0x00C0) >> 6 == 0x11`
        next_word = memory.get_word(pc + WORD_SIZE)
        [Instruction::MOVE.new(:sr, next_word, WORD_SIZE), LONGWORD_SIZE]
      else
        [:unknown, WORD_SIZE]
    end
    # for now, we advance by a word because we only support NOP
    [instruction, adv]
  end
end
