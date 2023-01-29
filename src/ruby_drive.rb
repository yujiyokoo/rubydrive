require 'rom'
require 'm68k'
require 'decoder'
require 'instruction'
require 'debug'

class RubyDrive
  attr_accessor :m68k
  def initialize(m68k)
    @m68k = m68k
  end

  def step
    instruction = m68k.next_instruction

    if instruction.is_a?(Instruction::NOP)
      # puts "found a NOP!"
    end
    instruction
  end

  def run
    m68k.running = true
    while m68k.running?
      instruction = step
      puts "instruction: #{instruction}"
      m68k.execute(instruction)
    end
  end
end
