class Ram
  ADDR_START = 0xFF0000
  attr_accessor :contents

  def initialize
    @contents = [0] * 0x10000
  end

  def copy_long_word(raw_addr, value)
    addr = raw_addr - ADDR_START
    raise AddressError if addr.odd?
    raise BusError unless contents[addr..addr+3]&.size &.>= 4
    contents[addr] = (value >> 24) & 0xFF
    contents[addr+1] = (value >> 16) & 0xFF
    contents[addr+2] = (value >> 8) & 0xFF
    contents[addr+3] = value & 0xFF
  end

  def get_long_word(raw_addr)
    addr = raw_addr - ADDR_START
    raise AddressError if addr.odd?
    raise BusError unless contents[addr..addr+3]&.size &.>= 4
    ((contents[addr] & 0xFF) << 24) |
     ((contents[addr+1] & 0xFF) << 16) |
     ((contents[addr+2] & 0xFF) << 8) |
     ((contents[addr+3] & 0xFF))
  end

  def copy_word(raw_addr, value)
    addr = raw_addr - ADDR_START
    raise AddressError if addr.odd?
    raise BusError unless contents[addr..addr+1]&.size &.>= 2
    contents[addr] = (value >> 8) & 0xFF
    contents[addr+1] = value & 0xFF
  end

  def get_word(raw_addr)
    addr = raw_addr - ADDR_START
    raise AddressError if addr.odd?
    raise BusError unless contents[addr..addr+3]&.size &.>= 4
    ((contents[addr] & 0xFF) << 8) | (contents[addr+1] & 0xFF)
  end
end
