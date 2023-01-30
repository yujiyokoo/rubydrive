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
