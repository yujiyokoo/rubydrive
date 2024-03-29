# class for managing multiple modules into a single memory/address space
class Memory
  RAM_START = 0xFF0000
  RAM_END = 0xFFFFFF
  ROM_END = 0x3FFFFF
  CONTROLLER_IO_START = 0xA10000
  CONTROLLER_IO_END = 0xA1001F
  TMSS_REGISTER_START = 0xA14000
  TMSS_REGISTER_END = 0xA14003
  VDP_REGISTER_START = 0xC00000
  VDP_REGISTER_END = 0xC0000F

  attr_accessor :rom, :controller_io, :ram, :tmss, :vdp
  def initialize(rom:, controller_io:, ram:, tmss:, vdp: VdpRegisters.new)
    raise RomSizeTooLarge if rom.size > 0x3FFFFF

    @rom = rom
    @controller_io = controller_io
    @ram = ram
    @tmss = tmss
    @vdp = vdp
  end

  def initial_sp
    rom.contents[0..3].pack("cccc").unpack("N")[0]
  end

  def initial_pc
    rom.contents[4..7].pack("cccc").unpack("N")[0]
  end

  def get_byte(addr)
    if rom_addr?(addr)
      rom.get_byte(addr)
    elsif ram_addr?(addr)
      ram.get_byte(addr)
    elsif controller_io_addr?(addr)
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

  def rom_addr?(addr) = 0 <= addr && addr <= ROM_END
  def controller_io_addr?(addr) = CONTROLLER_IO_START <= addr && addr <= CONTROLLER_IO_END
  def ram_addr?(addr) = RAM_START <= addr && addr <= RAM_END
  def tmss_register_addr?(addr)
    TMSS_REGISTER_START <= addr && addr <= TMSS_REGISTER_END
  end

  def vdp_register_addr?(addr)
    VDP_REGISTER_START <= addr && addr <= VDP_REGISTER_END && addr.even?
  end

  def write_long_word(addr, longword)
    write_value(addr, LONGWORD_SIZE, longword)
  end

  def write_word(addr, word)
    write_value(addr, WORD_SIZE, word)
  end

  def write_byte(addr, byte)
    write_value(addr, BYTE_SIZE, byte)
  end

  def write_value(addr, size, value)
    if ram_addr?(addr) && size == LONGWORD_SIZE
      ram.copy_long_word(addr, value)
    elsif ram_addr?(addr) && size == WORD_SIZE
      ram.copy_word(addr, value)
    elsif ram_addr?(addr) && size == BYTE_SIZE
      ram.copy_byte(addr, value)
    elsif controller_io_addr?(addr) && size == LONGWORD_SIZE
      controller_io.copy_long_word(addr, value)
    elsif controller_io_addr?(addr) && size == WORD_SIZE
      controller_io.copy_word(addr, value)
    elsif tmss_register_addr?(addr) && size == WORD_SIZE
      tmss.copy_word(addr, value)
    elsif tmss_register_addr?(addr) && size == LONGWORD_SIZE
      tmss.copy_long_word(addr, value)
    elsif vdp_register_addr?(addr) && size == WORD_SIZE
      vdp.copy_word(addr, value)
    elsif vdp_register_addr?(addr) && size == LONGWORD_SIZE
      vdp.copy_long_word(addr, value)
    else
      # TODO: PSG & Debug. See https://segaretro.org/Sega_Mega_Drive/Memory_map
      raise InvalidAddress.new("Unsupported write to addr: #{addr.to_s(16)}, size: #{size}, val: #{value}")
    end
  end
end
