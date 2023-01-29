require 'instruction'

class M68k
  attr_accessor :pc
  attr_accessor :sp
  attr_accessor :memory
  attr_accessor :decoder
  attr_accessor :running

  def initialize(memory, decoder)
    @sp = memory.contents[0..3].pack("cccc").unpack("N")[0]
    @pc = memory.contents[4..7].pack("cccc").unpack("N")[0]
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
    case instruction.class.name # TODO: better way to identify class?
      when 'Instruction::NOP'
        nil # don't do anything as it's a NOP
      else
        raise UnsupportedInstruction
    end
  end
end

class UnsupportedInstruction < Exception
end
