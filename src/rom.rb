class Rom
  attr_accessor :contents

  def initialize(contents)
    @contents = (contents)
  end

  def at(addr)
    contents[addr]
  end

  def get_word(addr)
    raise AddressError if addr.odd?
    raise BusError if contents[addr].nil?
    (contents[addr] << 8) | (contents[addr+1])
  end
end

class AddressError < Exception
end

class BusError < Exception
end
