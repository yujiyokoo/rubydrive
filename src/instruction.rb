class Instruction
  LONGWORD_SIZE = 4
  WORD_SIZE = 2
  BYTE_SIZE = 1
  
  class MOVE_TO_SR < Struct.new('MOVE_TO_SR', :value) # destination is SR, size is word
  end

  class NOP < Struct.new('NOP')
  end
end
