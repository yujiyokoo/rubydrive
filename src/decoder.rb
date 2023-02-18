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
          [Instruction::TST.new(Target::AbsoluteLong.new(next_long_word), LONGWORD_SIZE), S_3WORD]
        elsif size_word?(lower) && addressing_absolute_long?(lower)
          next_long_word = memory.get_long_word(pc + S_1WORD)
          [Instruction::TST.new(Target::AbsoluteLong.new(next_long_word), WORD_SIZE), S_3WORD]
        else
          [:unknown, S_1WORD]
        end
      when upper & 0xC0 == 0 && (upper & 0x30) >> 4 != 0 # MOVE
        size = get_move_size(upper)
        source, destination, data_mv = get_move_source_and_destination(word, memory, pc)
        [Instruction::MOVE.new(source, destination, size), S_1WORD + data_mv]
      when upper & 0xF0 == 0x60
        # BRA, BSR, Bcc
        if [0xF0, 0xF1].include?(upper & 0xFF == 0xF0) # BRA or BSR
          raise UnsupportedInstruction.new("BRA or BSR not supported yet")
        end
        displacement, size, mv = if lower == 0 # word displacement
          [memory.get_word(pc + S_1WORD), WORD_SIZE, S_2WORD]
        else
          [lower, SHORT_SIZE, S_1WORD]
        end

        if upper & 0x0F == 0x06 # BNE
          [Instruction::BNE.new(Target::AddrDisplacement.new(displacement), size), mv]
        elsif upper & 0x0F == 0x07 # BNE
          [Instruction::BEQ.new(Target::AddrDisplacement.new(displacement), size), mv]
        else
          raise UnsupportedInstruction.new("Bcc 0x#{word.to_s(16)} not supported yet")
        end
      when is_lea?(upper)
        if is_pc_with_displacement?(lower)
          next_word = memory.get_word(pc + S_1WORD)
          register = upper_An(upper)
          [Instruction::LEA.new(Target::PcDisplacement.new(next_word), register), S_2WORD]
        else
          [:unknown, S_1WORD]
        end
      when is_andi?(upper)
        next_word = memory.get_word(pc + S_1WORD)
        source = Target::Immediate.new(next_word)
        dest, size = get_lower_target_and_size(lower & 0x3F, memory, pc)
        [Instruction::ANDI.new(source, dest, size), S_2WORD]
      else
        raise UnsupportedInstruction.new("cannot decode '0x#{word.to_s(16)}'")
    end

    [instruction, adv]
  end

  def is_andi?(upper_byte) = upper_byte == 0x02

  def get_lower_size(lower_byte)
    case (lower_byte >> 6) & 0x03
      when 0x00
        BYTE_SIZE
      when 0x01
        WORD_SIZE
      when 0x10
        LONG_SIZE
      else
        raise UnsupportedSize
    end
  end

  def get_move_source_and_destination(word, memory, pc)
    src, mvs = get_move_source(word & 0xFF, memory, pc)
    dest, mvd = get_move_destination((word & 0x0FC0) >> 6, memory, pc + mvs)
    [src, dest, mvs + mvd]
  end

  def get_move_destination(six_bits, memory, pc)
    # Note this is 'swapped' compared to other 6 bit destinations in lower byte
    mode = six_bits & 0x7
    regnum = (six_bits & 0x38) >> 3
    if mode == 0 # Dn register
      regnames = [:d0, :d1, :d2, :d3, :d4, :d5, :d6, :d7]
      [Target::Register.new(regnames[regnum]), 0]
    elsif mode == 0b111 && regnum == 0b001 # ABS long
      [Target::AbsoluteLong.new(memory.get_long_word(pc + S_1WORD)), LONGWORD_SIZE]
    elsif mode == 0b111 && regnum == 0b000 # ABS short
      raise UnsupportedDestination.new("abs sort")
    else
      puts "#{mode.to_s(2)}, #{regnum.to_s(2)}"
      raise UnsupportedDestination
    end
  end

  def get_move_source(byte, memory, pc) # TODO: could memory and pc be not passed
    get_lower_target(byte, memory, pc)
  end

  # size may or may not be determined prior to this function
  def get_lower_target_and_size(byte, memory, pc)
    size = get_lower_size(byte)
    # currently this fuction is only called from ANDI, which is "immediate" so we can drop the 'mv'
    target, _ = get_lower_target(byte, memory, pc)
    [target, size]
  end

  def get_lower_target(byte, memory, pc)
    mode = (byte & 0x38) >> 3
    regnum = byte & 0x7
    if mode == 0x7 && regnum == 0x1 # AbsoluteLong
      next_long_word = memory.get_long_word(pc + S_1WORD)
      [Target::AbsoluteLong.new(next_long_word), LONGWORD_SIZE]
    elsif mode == 0x00 && regnum == 0x0 # register d0
      next_word = memory.get_word(pc + S_1WORD)
      [Target::Register.new(:d0), WORD_SIZE]
    elsif mode == 0b111 && regnum == 0b100
      next_long_word = memory.get_long_word(pc + S_1WORD)
      [Target::Immediate.new(next_long_word), LONGWORD_SIZE]
    else
      raise UnsupportedSource
    end
  end

  def get_move_size(byte)
    case (byte & 0x30) >> 4
    when 0b01
      return BYTE_SIZE
    when 0b11
      return WORD_SIZE
    when 0b10
      return LONGWORD_SIZE
    else
      raise InvalidSize
    end
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
