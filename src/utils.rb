def debugpr(*args)
  puts(*args) if ENV['DEBUG']
end

LONGWORD_SIZE = 4
WORD_SIZE = 2
BYTE_SIZE = 1
SHORT_SIZE = 1 # For the 'lower byte' in BRA etc. Should this be zero?

class UnsupportedAddress < Exception
end

class RomSizeTooLarge < Exception
end

class UnsupportedInstruction < Exception
end

class UnsupportedTarget < Exception
end

class UnsupportedRegister < Exception
end

class UnsupportedDestination < Exception
end

class UnsupportedSource < Exception
end

class InvalidSize < Exception
end

class InvalidAddress < Exception
end

def to_short_signed(num)
  raise RuntimeException.new("negative num not supported: #{num}") if num < 0

  if num <= 127
    return num
  else
    return num - 2**8
  end
end

def to_word_signed(num)
  raise RuntimeException.new("negative num not supported: #{num}") if num < 0

  if num <= 32767
    return num
  else
    return num - 2**16
  end
end

