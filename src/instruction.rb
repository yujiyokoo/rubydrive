class Instruction
  # TODO: 'value' will have to support EA later
  class MOVE_TO_SR < Struct.new('MOVE_TO_SR', :value) # destination is SR, size is word
  end

  class NOP < Struct.new('NOP')
  end

  class TST < Struct.new('TST', :target, :size)
  end

  class BNE < Struct.new('BNE', :target, :size) # size is SHORT (byte inside the instruction word) or WORD
  end

  class LEA < Struct.new('LEA', :target, :destination)
  end

  class STOP < Struct.new('STOP', :value)
  end

  class MOVE < Struct.new('MOVE', :target, :destination, :size)
  end

  class ANDI < Struct.new('ANDI', :target, :destination, :size)
  end
end
