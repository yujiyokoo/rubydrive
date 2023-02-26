require 'rom'
require 'm68k'
require 'decoder'
require 'instruction'
require 'utils'

class RubyDrive
  attr_accessor :m68k
  def initialize(m68k)
    @m68k = m68k
  end

  def get_instruction
    instruction, size = m68k.current_instruction

    [instruction, size]
  end

  def run
    m68k.running = true
    while m68k.running?
      debugpr "--"
      instruction, size = get_instruction
      debugpr "instruction: #{instruction}"
      m68k.execute(instruction)
      m68k.increment_pc(size)
    end
  end
end
