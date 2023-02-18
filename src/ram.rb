class Ram
  attr_accessor :contents

  def initialize
    @contents = [0] * 0x10000
  end


  def copy_long_word(raw_addr, value)
    addr = raw_addr - 0xFF0000
    raise AddressError if addr.odd?
    raise BusError if !(contents[addr..addr+3]&.size &.>= 4)
    contents[addr] = (value >> 24) & 0xFF
    contents[addr+1] = (value >> 16) & 0xFF
    contents[addr+2] = (value >> 8) & 0xFF
    contents[addr+3] = value & 0xFF
  end

  def get_long_word(raw_addr)
    addr = raw_addr - 0xFF0000
    raise AddressError if addr.odd?
    raise BusError if !(contents[addr..addr+3]&.size &.>= 4)
    ((contents[addr] & 0xFF) << 24) |
     ((contents[addr+1] & 0xFF) << 16) |
     ((contents[addr+2] & 0xFF) << 8) |
     ((contents[addr+3] & 0xFF))
  end
end
