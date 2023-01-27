class M68k
  attr_accessor :pc
  attr_accessor :memory
  attr_accessor :decoder
  attr_accessor :running

  def initialize(memory, decoder)
    @pc = 0
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
    case instruction
      when :nop
        # don't do anything as it's a NOP
      else
        raise UnsupportedInstruction
    end
  end
end

class UnsupportedInstruction < Exception
end
