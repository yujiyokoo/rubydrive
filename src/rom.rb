class Rom
  attr_accessor :contents

  def initialize(contents)
    @contents = (contents)
  end

  def at(addr)
    contents[addr]
  end

  # TODO: need a more efficient way of storing and getting bytes
  def get_word(addr)
    raise AddressError if addr.odd?
    raise BusError if contents[addr].nil?
    (contents[addr] << 8) | ((contents[addr+1] & 0xFF))
  end
end

class AddressError < Exception
end

class BusError < Exception
end
