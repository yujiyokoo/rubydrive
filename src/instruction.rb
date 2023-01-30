class Instruction
  # TODO: 'value' will have to support EA later
  class MOVE_TO_SR < Struct.new('MOVE_TO_SR', :value) # destination is SR, size is word
  end

  class NOP < Struct.new('NOP')
  end

  class TST < Struct.new('TST', :target, :size)
  end

  class BNE < Struct.new('BNE', :target, :size) # size is SHORT or WORD
  end
end
