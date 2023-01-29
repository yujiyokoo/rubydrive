class Rom
  attr_accessor :contents

  def initialize(contents)
    @contents = (contents)
  end

  def size = contents.size

  def get_byte(addr)
    raise BusError if contents[addr].nil?
    contents[addr]
  end

  # TODO: need a more efficient way of storing and getting bytes
  def get_word(addr)
    raise AddressError if addr.odd?
    raise BusError if !(contents[addr..addr+1]&.size &.>= 2)
    (contents[addr] << 8) | ((contents[addr+1] & 0xFF))
  end

  def get_long_word(addr)
    raise AddressError if addr.odd?
    raise BusError if !(contents[addr..addr+3]&.size &.>= 4)
    ((contents[addr] & 0xFF) << 24) |
     ((contents[addr+1] & 0xFF) << 16) |
     ((contents[addr+2] & 0xFF) << 8) |
     ((contents[addr+3] & 0xFF))
  end
end

class AddressError < Exception
end

class BusError < Exception
end
