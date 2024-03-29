require 'instruction'

require 'target'
require 'displacement'
require 'condition'
require 'utils'

class Decoder
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
        source, destination, data_mv = get_move_source_and_destination(word, memory, pc, size)
        [Instruction::MOVE.new(source, destination, size), S_1WORD + data_mv]
      when upper & 0xF0 == 0x60
        # BRA, Bcc
        if 0x60 == (upper & 0xFF) # BRA
          raise UnsupportedInstruction.new("BRA not supported yet")
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
        elsif upper & 0x0F == 0x01 # BSR
          # For SHORT, it's part of instruction word. For WORD, it's next word
          instruction_size = size * 2
          [Instruction::BSR.new(Target::AddrDisplacement.new(displacement), size), instruction_size]
        else
          raise UnsupportedInstruction.new("Bcc 0x#{word.to_s(16)} not supported yet")
        end
      when is_lea?(word)
        if pc_with_displacement?(lower)
          next_word = memory.get_word(pc + S_1WORD)
          register = upper_An(upper)
          [Instruction::LEA.new(Target::PcDisplacement.new(next_word), register), S_3WORD]
        elsif absolute_long?(lower)
          next_word = memory.get_long_word(pc + S_1WORD)
          register = upper_An(upper)
          [Instruction::LEA.new(Target::AbsoluteLong.new(next_word), register), S_3WORD]
        else
          [:unknown, S_1WORD]
        end
      when is_andi?(upper)
        next_word = memory.get_word(pc + S_1WORD)
        source = Target::Immediate.new(next_word)
        dest, size = get_lower_target_and_size(lower & 0x3F, memory, pc)
        [Instruction::ANDI.new(source, dest, size), S_2WORD]
      when is_dbcc?(upper, lower)
        if (upper & 0x0F) == 0x01 # condition: false
          displacement = Displacement.new(to_word_signed(memory.get_word(pc + S_1WORD)))
          data_reg = data_reg(lower & 0b111)
          [Instruction::DBcc.new(Condition::False, Target::Register.new(data_reg), displacement), S_1WORD]
        else
          raise UnsupportedInstruction.new("DBcc not DBF")
        end
      when word == 0x4E75
        [Instruction::RTS.new, S_1WORD] # the second param is ignored so it doesn't really matter
      when subq?(upper)
        data = (upper & 0x0E) >> 1
        source = Target::Immediate.new(data)
        size = get_lower_size(lower)
        dest, _ = get_lower_target(lower, memory, pc, size)
        [Instruction::SUBQ.new(source, dest, size), S_1WORD]
      else
        raise UnsupportedInstruction.new("cannot decode '0x#{word.to_s(16)}'")
    end

    [instruction, adv]
  end

  def subq?(upper_byte)
    upper_byte & 0xF1 == 0x51
  end

  def data_reg(num)
    DREG_NAMES[num]
  end

  def is_dbcc?(upper_byte, lower_byte) = (upper_byte & 0xF0) == 0X50 && (lower_byte & 0xF8) == 0xC8

  def is_andi?(upper_byte) = upper_byte == 0x02

  def get_lower_size(lower_byte)
    case (lower_byte >> 6) & 0x03
      when 0b00
        BYTE_SIZE
      when 0b01
        WORD_SIZE
      when 0b10
        LONGWORD_SIZE
      else
        raise InvalidSize
    end
  end

  def get_move_source_and_destination(word, memory, pc, size)
    src, mvs = get_move_source(word & 0xFF, memory, pc, size)
    dest, mvd = get_move_destination((word & 0x0FC0) >> 6, memory, pc + mvs)
    [src, dest, mvs + mvd]
  end


  DREG_NAMES = [:d0, :d1, :d2, :d3, :d4, :d5, :d6, :d7]
  AREG_NAMES = [:a0, :a1, :a2, :a3, :a4, :a5, :a6, :a7]

  def get_move_destination(six_bits, memory, pc)
    # Note this is 'swapped' compared to other 6 bit destinations in lower byte
    mode = six_bits & 0x7
    regnum = (six_bits & 0x38) >> 3
    if mode == 0 # Dn register
      [Target::Register.new(DREG_NAMES[regnum]), 0]
    elsif mode == 0b001 # An register
      [Target::Register.new(AREG_NAMES[regnum]), 0]
    elsif mode == 0b011 # Register Indirect with post increment
      [Target::RegisterIndirect.new(AREG_NAMES[regnum], true), 0]
    elsif mode == 0b111 && regnum == 0b001 # ABS long
      [Target::AbsoluteLong.new(memory.get_long_word(pc + S_1WORD)), LONGWORD_SIZE]
    elsif mode == 0b111 && regnum == 0b000 # ABS short
      raise UnsupportedDestination.new("abs short")
    elsif mode == 0b010 # (An)
      [Target::RegisterIndirect.new(AREG_NAMES[regnum], false), 0]
    elsif mode == 0b101 # Address with displacement
      next_word = memory.get_word(pc + S_1WORD)
      [Target::RegisterIndirectDisplacement.new(AREG_NAMES[regnum], next_word), 2]
    else
      raise UnsupportedDestination.new("unimplemented dest: #{mode.to_s(2).rjust(3, "0")}, #{regnum.to_s(2).rjust(3, "0")}")
    end
  end

  def get_move_source(byte, memory, pc, size) # TODO: could memory and pc be not passed
    get_lower_target(byte, memory, pc, size)
  end

  # size may or may not be determined prior to this function
  def get_lower_target_and_size(byte, memory, pc)
    size = get_lower_size(byte)
    # currently get_lower_target_and_size is only called from ANDI, which is "immediate" so we can drop the 'mv'
    target, _ = get_lower_target(byte, memory, pc, size)
    [target, size]
  end

  def get_lower_target(byte, memory, pc, size)
    mode = (byte & 0x38) >> 3
    regnum = byte & 0x7
    if mode == 0x7 && regnum == 0x1 # AbsoluteLong - can ignore size
      next_long_word = memory.get_long_word(pc + S_1WORD)
      [Target::AbsoluteLong.new(next_long_word), LONGWORD_SIZE]
    elsif mode == 0x00 && regnum == 0x0 # register d0
      [Target::Register.new(:d0), size]
    elsif mode == 0x01
      [Target::Register.new(AREG_NAMES[regnum]), size]
    elsif mode == 0b111 && regnum == 0b100 # immediate
      immediate_val = if size == LONGWORD_SIZE
        memory.get_long_word(pc + S_1WORD)
      elsif size == WORD_SIZE
        memory.get_word(pc + S_1WORD)
      else
        raise UnsupportedSource
      end
      [Target::Immediate.new(immediate_val), size]
    elsif mode == 0b011 # address with post increment
      [Target::RegisterIndirect.new(AREG_NAMES[regnum], true), 0]
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

  def pc_with_displacement?(byte)
    (byte & 0x3F) == 0x3A
  end

  def absolute_long?(byte)
    (byte & 0x3F) == 0x39
  end

  def upper_An(byte)
    regnames = AREG_NAMES
    regnum = (byte & 0x0E) >> 1
    reg = regnames[regnum]

    raise UnsupportedRegister if reg.nil?

    reg
  end

  def is_lea?(word)
    (word & 0xF1C0) == 0x41C0
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
