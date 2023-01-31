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

    instruction, adv = case
      when [upper, lower] == [0x4E, 0x71] # NOP
        [Instruction::NOP.new, S_1WORD]
      when [upper, lower] == [0x4E, 0x72]
        next_word = memory.get_word(pc + S_1WORD)
        [Instruction::STOP.new(next_word), S_2WORD]
      when [upper, lower] == [0x46, 0xFC] # move a (16bit) word to status register
        # Here we've matched entire long word but if you only match the upper word,
        # you'd need something like `if (next_word & 0x00C0) >> 6 == 0x11`
        next_word = memory.get_word(pc + S_1WORD)
        [Instruction::MOVE_TO_SR.new(next_word), S_2WORD]
      when upper == 0x4a # TST (or TAS)
        if size_long?(lower) && addressing_absolute_long?(lower)
          next_long_word = memory.get_long_word(pc + S_1WORD)
          [Instruction::TST.new(Target::Absolute.new(next_long_word), LONGWORD_SIZE), S_3WORD]
        elsif size_word?(lower) && addressing_absolute_long?(lower)
          next_long_word = memory.get_long_word(pc + S_1WORD)
          [Instruction::TST.new(Target::Absolute.new(next_long_word), WORD_SIZE), S_3WORD]
        else
          [:unknown, S_1WORD]
        end
      when upper == 0x66 # BNE (eventually 0x6 for Bccc?)
        [Instruction::BNE.new(Target::AddrDisplacement.new(lower), SHORT_SIZE), S_1WORD]
      when is_lea?(upper)
        if is_pc_with_displacement?(lower)
          next_word = memory.get_word(pc + S_1WORD)
          register = upper_An(upper)
          [Instruction::LEA.new(Target::PcDisplacement.new(next_word), register), S_2WORD]
        else
          [:unknown, S_1WORD]
        end
      else
        [:unknown, S_1WORD]
    end

    [instruction, adv]
  end

  def is_pc_with_displacement?(byte)
    (byte & 0x3F) == 0x3A
  end

  def upper_An(byte)
    regnames = [:a0, :a1, :a2, :a3, :a4, :a5, :a6, :a7]
    regnum = (byte & 0x0E) >> 1
    reg = regnames[regnum]

    raise UnsupportedRegister if reg.nil?

    reg
  end

  def is_lea?(byte)
    (byte & 0xF0) >> 4 == 0b0100
  end

  def size_long?(byte)
    (byte & 0xC0) >> 6 == 0b10
  end

  def size_word?(byte)
    (byte & 0xC0) >> 6 == 0b01
  end

  def addressing_absolute_long?(byte)
    (byte & 0x38) >> 3 == 0b111 && (byte & 0x07) == 0b001
  end
end
