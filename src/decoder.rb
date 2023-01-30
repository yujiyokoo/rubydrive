require 'instruction'

require 'target'

class Decoder
  S_3WORD = 6
  S_2WORD = 4
  S_1WORD = 2
  def get_instruction(memory, pc)
    # According to https://www.nxp.com/files-static/archives/doc/ref_manual/M68000PRM.pdf
    # "instructions consist of at least one word"
    # "The first word of the instruction, called the simple effective address operation word,
    #  specifies the length of the instruction, the effective addressing mode, and the
    #  operation to be performed"
    word = memory.get_word(pc)
    upper = word >> 8
    lower = word & 0xFF

    debugpr "looking at instruction word at #{pc.to_s(16)}: #{word.to_s(16)}"

    instruction, adv = case [upper, lower]
      in [0x4E, 0x71] # NOP
        [Instruction::NOP.new, S_1WORD]
      in [0x46, 0xFC] # move a (16bit) word to status register
        # Here we've matched entire long word but if you only match the upper word,
        # you'd need something like `if (next_word & 0x00C0) >> 6 == 0x11`
        next_word = memory.get_word(pc + S_1WORD)
        [Instruction::MOVE_TO_SR.new(next_word), S_2WORD]
      in [0x4a, Integer] # TST (or TAS)
        if (lower & 0xC0) >> 6 == 0b10 && (lower & 0x38) >> 3 == 0b111 && (lower & 0x07) == 0b001
          next_long_word = memory.get_long_word(pc + S_1WORD)
          [Instruction::TST.new(Target::Absolute.new(next_long_word), LONGWORD_SIZE), S_3WORD]
        else
          [:unknown, S_1WORD]
        end
      in [0x66, Integer] # BNE (eventually 0x6 for Bccc?)
        [Instruction::BNE.new(Target::Displacement.new(lower), SHORT_SIZE), S_1WORD]
      else
        [:unknown, S_1WORD]
    end

    [instruction, adv]
  end
end
