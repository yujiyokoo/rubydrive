require 'utils'
require 'instruction'

class M68k
  attr_accessor :registers # a0-a7, d0-d7
  attr_accessor :pc # Program Counter
  attr_accessor :sr # Status Register
  attr_accessor :memory
  attr_accessor :decoder
  attr_accessor :running

  def initialize(memory, decoder)
    @registers = {
      a0: 0, a1: 0, a2: 0, a3: 0, a4: 0, a5: 0, a6: 0, a7: 0,
      d0: 0, d1: 0, d2: 0, d3: 0, d4: 0, d5: 0, d6: 0, d7: 0,
    }
    self.sp = memory.initial_sp
    @pc = memory.initial_pc
    @sr = 0
    @memory = memory
    @decoder = decoder
    @running = false
  end

  # addres register 7 is also stack pointer
  def sp = registers[:a7]
  def sp=(val)
    registers[:a7] = val
  end

  def running?
    running
  end

  def next_instruction
    instruction, size = decoder.get_instruction(memory, @pc)
    @pc += size
    instruction
  end

  def execute(instruction)
    debugpr(instruction.class.name)
    case instruction.class.name # TODO: better way to identify class?
    when 'Instruction::NOP'
      nil # don't do anything as it's a NOP
    when 'Instruction::MOVE_TO_SR'
      @sr = (0xFF & instruction.value) # Copy only the lower word to SR
    when 'Instruction::MOVE'
      if instruction.target.is_a?(Target::AbsoluteLong) && instruction.target_size == BYTE_SIZE && instruction.destination.is_a?(Target::Register)
        source_byte = memory.get_byte(instruction.target.address)
        registers[instruction.destination.name] = (registers[instruction.destination.name] & 0xFF00) | source_byte
      elsif instruction.target.is_a?(Target::Immediate) && instruction.target_size == LONGWORD_SIZE && instruction.destination.is_a?(Target::AbsoluteLong)
        source_lw = instruction.target.value
        dest_addr = instruction.destination.address
        memory.write_long_word(dest_addr, source_lw)
        memory
      else
        raise UnsupportedInstruction.new("Unsupported: #{instruction}")
      end
    when 'Instruction::TST'
      value = read_target(instruction, memory)
      @sr = sr | 0x04 if value == 0
      @sr = sr | 0x08 if negative?(value, instruction.target_size)
      @sr = sr & 0x0C
    when 'Instruction::BNE'
      if !z_flag_on?
        @pc += read_target(instruction, memory)
      end
    when 'Instruction::BEQ'
      if z_flag_on?
        @pc += read_target(instruction, memory)
      end
    when 'Instruction::BSR'
      @pc += read_target(instruction, memory)
    when 'Instruction::LEA'
      raise UnsupportedInstruction unless instruction.target.is_a?(Target::PcDisplacement)

      displacement = read_target(instruction, memory)
      registers[instruction.destination] = pc + displacement
    when 'Instruction::STOP'
      @sr = instruction.value
      self.running = false
    when 'Instruction::ANDI'
      raise UnsupportedInstruction unless instruction.target_size == BYTE_SIZE
      raise UnsupportedInstruction unless instruction.target.is_a?(Target::Immediate)
      raise UnsupportedInstruction unless instruction.destination.is_a?(Target::Register)
      result = (instruction.target.value & 0xFF) & (registers[instruction.destination.name] & 0xFF)
      registers[instruction.destination.name] = (registers[instruction.destination.name] & 0xFFFFFF00) | result
      @sr &= 0xFFFFFFFC # set V & C zero

      # setting the N flag
      n = (result & 0x80) == 0x80 # currently only supporting byte...
      @sr |= 0x00000004 if n

      z = (result == 0)
      @sr |= 0x00000008 if z
    else
      raise UnsupportedInstruction.new(instruction.class.name)
    end
  end

  def z_flag_on? = sr & 0x04 != 0

  def negative?(value, size)
    if size == LONGWORD_SIZE
      (value & 0xFFFFFFFF) >> 31 == 0b1
    elsif size == WORD_SIZE
      (value & 0xFFFF) >> 15 == 0b1
    else
      raise UnsupportedInstruction
    end
  end

  def read_target(instruction, memory)
    case instruction.target.class.name
    when 'Target::AbsoluteLong' # TODO: better way to identify class?
      if instruction.target_size == LONGWORD_SIZE
        memory.get_long_word(instruction.target.address)
      elsif instruction.target_size == WORD_SIZE
        memory.get_word(instruction.target.address)
      else
        raise UnsupportedTarget.new("Unsupported absolute target target_size")
      end
    when 'Target::AddrDisplacement'
      if instruction.target_size == SHORT_SIZE
        to_short_signed(instruction.target.value)
      else
        raise UnsupportedTarget.new("Unsupported addr displacement target target_size")
      end
    when 'Target::PcDisplacement' # size should always be long word
      memory.get_long_word(instruction.target.value)
    else
      raise UnsupportedTarget.new("Unsupported target type")
    end
  end

  def to_short_signed(num)
    raise RuntimeException.new("negative num not supported: #{num}") if num < 0

    if num <= 127
      return num
    else
      return num - 2**8
    end
  end
end
