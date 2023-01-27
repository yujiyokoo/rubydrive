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

    instruction = case word
      when 0x4E71
        :nop
      else
        :unknown
    end
    # for now, we advance by a word because we only support NOP
    [instruction, WORD_SIZE]
  end
end
