class ControllerIO
  attr_accessor :return_value

  def initialize(return_value)
    @return_value = return_value
  end

  def get_byte(addr)
    if 0xA10000 <= addr and addr <= 0xA1001F
      return_value & 0xFF # just preset value at this point
    else
      raise UnsupportedAddress
    end
  end

  def get_word(addr)
    if 0xA10000 <= addr and addr <= 0xA1001F
      return_value & 0xFFFF # just preset value at this point
    else
      raise UnsupportedAddress
    end
  end

  def get_long_word(addr)
    if 0xA10000 <= addr and addr <= 0xA1001F
      return_value & 0xFFFFFFFF # just preset value at this point
    else
      raise UnsupportedAddress
    end
  end
end
