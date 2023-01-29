# class for managing multiple modules into a single memory/address space
class Memory
  attr_accessor :rom, :controller_io
  def initialize(rom:, controller_io:)
    raise RomSizeTooLarge if rom.size > 0x3FFFFF

    @rom = rom
    @controller_io = controller_io
  end

  def initial_sp
    rom.contents[0..3].pack("cccc").unpack("N")[0]
  end

  def initial_pc
    rom.contents[4..7].pack("cccc").unpack("N")[0]
  end

  def get_byte(addr)
    if addr <= 0x3FFFFF
      rom.get_byte(addr)
    elsif 0xA10000 <= addr and addr <= 0xA1001F
      controller_io.get_byte(addr)
    else
      raise UnsupportedAddress
    end
  end

  def get_word(addr)
    if addr <= 0x3FFFFF
      rom.get_word(addr)
    elsif 0xA10000 <= addr and addr <= 0xA1001F
      controller_io.get_word(addr)
    else
      raise UnsupportedAddress
    end
  end

  def get_long_word(addr)
    if addr <= 0x3FFFFF
      rom.get_long_word(addr)
    elsif 0xA10000 <= addr and addr <= 0xA1001F
      controller_io.get_long_word(addr)
    else
      raise UnsupportedAddress
    end
  end
end

class UnsupportedAddress < Exception
end

class RomSizeTooLarge < Exception
end
