class ControllerIO
  attr_accessor :return_value

  CONTROLLER_IO_START = 0xA10000
  CONTROLLER_IO_END = 0xA1001F

  def initialize(return_value)
    @return_value = return_value
  end

  def valid_address?(addr)
    CONTROLLER_IO_START <= addr && addr <= CONTROLLER_IO_END
  end

  def get_byte(addr)
    raise UnsupportedAddress unless valid_address?(addr)
    return_value & 0xFF # just preset value at this point
  end

  def get_word(addr)
    raise UnsupportedAddress unless valid_address?(addr)
    return_value & 0xFFFF # just preset value at this point
  end

  def get_long_word(addr)
    raise UnsupportedAddress unless valid_address?(addr)
    return_value & 0xFFFFFFFF # just preset value at this point
  end

  def copy_long_word(addr, value)
    raise UnsupportedAddress unless valid_address?(addr)
    # peripheral unimplemented at this stage
  end

  def copy_word(addr, value)
    copy_long_word(addr, value)
  end
end
