require 'rom'
require 'm68k'
require 'decoder'

class RubyDrive
  attr_accessor :m68k
  def initialize(m68k)
    @m68k = m68k
  end

  def step
    instruction = m68k.next_instruction

    if instruction == :nop
      puts "found a NOP!"
    end
    instruction
  end

  def run
    m68k.running = true
    while m68k.running?
      instruction = step
      m68k.execute(instruction)
    end
  end
end
