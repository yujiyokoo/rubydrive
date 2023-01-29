class Instruction
  LONGWORD_SIZE = 4
  WORD_SIZE = 2
  BYTE_SIZE = 1
  
  class MOVE < Struct.new('MOVE', :destination, :value, :size)
  end

  class NOP < Struct.new('NOP')
  end
end
