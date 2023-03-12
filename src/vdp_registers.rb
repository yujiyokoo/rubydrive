class VdpRegisters
  attr_accessor :registers
  def initialize
    @registers = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  end

  def copy_word(addr, value)
    register_index = addr - 0xC00000
    @registers[register_index] = (value & 0xFF00) >> 8
    @registers[register_index+1] = value & 0x00FF
  end

  def copy_long_word(addr, value)
    register_index = addr - 0xC00000
    @registers[register_index] = (value >> 24) & 0xFF
    @registers[register_index+1] = (value >> 16) & 0xFF
    @registers[register_index+2] = (value >> 8) & 0xFF
    @registers[register_index+3] = value & 0xFF
  end
end
