require 'instruction'

class M68k
  attr_accessor :pc # Program Counter
  attr_accessor :sp # Stack Pointer
  attr_accessor :sr # Status Register
  attr_accessor :memory
  attr_accessor :decoder
  attr_accessor :running

  def initialize(memory, decoder)
    @sp = memory.initial_sp
    @pc = memory.initial_pc
    @sr = 0
    @memory = memory
    @decoder = decoder
    @running = false
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
    when 'Instruction::TST'
      value = read_target(instruction, memory)
      @sr = sr | 0x04 if value == 0
      @sr = sr | 0x08 if negative?(value, instruction.size)
      @sr = sr & 0x0C
    else
      raise UnsupportedInstruction
    end
  end

  # TODO: move somewhere?
  def negative?(value, size)
    if size != LONGWORD_SIZE
      raise UnsupportedInstruction
    else
      (value & 0xFFFFFFFF) >> 31 == 0b1
    end
  end

  def read_target(instruction, memory)
    # let's support absolute address first
    case instruction.target.class.name
    when 'Target::Absolute' # TODO: better way to identify class?
      if instruction.size == LONGWORD_SIZE
        #puts "instruction: #{instruction}"
        #puts "long word: #{memory.get_long_word(instruction.target.address)}"
        memory.get_long_word(instruction.target.address)
      else
        raise UnsupportedTarget("Unsupported absolute target size")
      end
    else
      raise UnsupportedTarget("Unsupported target type")
    end
  end
end

class UnsupportedInstruction < Exception
end

class UnsupportedTarget < Exception
end
