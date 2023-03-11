class Tmss
  TMSS_REGISTER_START = 0xA14000
  attr_accessor :registers
  def initialize
    @registers = 0 # represented in 1 var. It's 32 bit
  end

  def copy_word(addr, value)
    if addr == 0xA14000
      @registers = (@registers & 0x0000FFFF) | ((value << 16) & 0xFFFF0000)
    elsif addr == 0xA14002
      @registers = (@registers & 0xFFFF0000) | (value & 0x0000FFFF)
    else
      raise UnsupportedAddress
    end
  end

  def copy_long_word(addr, value)
    raise UnsupportedAddress unless addr == 0xA14000

    @registers = value
  end
end
