# class for managing multiple modules into a single memory/address space
class Memory
  RAM_START = 0xFF0000
  RAM_END = 0xFFFFFF
  ROM_END = 0x3FFFFF
  CONTROLLER_IO_START = 0xA10000
  CONTROLLER_IO_END = 0xA1001F
  TMSS_REGISTER_START = 0xA14000
  TMSS_REGISTER_END = 0xA14003

  attr_accessor :rom, :controller_io, :ram
  def initialize(rom:, controller_io:, ram:)
    raise RomSizeTooLarge if rom.size > 0x3FFFFF

    @rom = rom
    @controller_io = controller_io
    @ram = ram
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
    if rom_addr?(addr)
      rom.get_word(addr)
    elsif ram_addr?(addr)
      ram.get_word(addr)
    elsif controller_io_addr?(addr)
      controller_io.get_word(addr)
    else
      raise UnsupportedAddress
    end
  end

  def get_long_word(addr)
    if rom_addr?(addr)
      rom.get_long_word(addr)
    elsif ram_addr?(addr)
      ram.get_long_word(addr)
    elsif controller_io_addr?(addr)
      controller_io.get_long_word(addr)
    else
      raise UnsupportedAddress
    end
  end

  def rom_addr?(addr) = addr <= ROM_END
  def controller_io_addr?(addr) = CONTROLLER_IO_START <= addr && addr <= CONTROLLER_IO_END
  def ram_addr?(addr) = RAM_START <= addr && addr <= RAM_END
  def other_valid_addr?(addr)
    TMSS_REGISTER_START <= addr && addr <= TMSS_REGISTER_END
  end

  def write_long_word(addr, longword)
    write_value(addr, LONGWORD_SIZE, longword)
  end

  def write_word(addr, word)
    write_value(addr, WORD_SIZE, word)
  end

  def write_value(addr, size, value)
    if ram_addr?(addr) && size == LONGWORD_SIZE
      ram.copy_long_word(addr, value)
    elsif ram_addr?(addr) && size == WORD_SIZE
      ram.copy_word(addr, value)
    elsif controller_io_addr?(addr) && size == LONGWORD_SIZE
      controller_io.copy_long_word(addr, value)
    elsif controller_io_addr?(addr) && size == WORD_SIZE
      controller_io.copy_word(addr, value)
    elsif other_valid_addr?(addr)
      # Unimplemented stuff like TMSS
    else
      raise InvalidAddress.new("Unsupported write to addr: #{addr}, size: #{size}, val: #{value}")
    end
  end
end
