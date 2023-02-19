class Instruction
  # TODO: 'value' will have to support EA later
  class MOVE_TO_SR < Struct.new('MOVE_TO_SR', :value) do # destination is SR, size is word
    def initialize(value) = super; end
  end

  class NOP < Struct.new('NOP')
  end

  class TST < Struct.new('TST', :target, :target_size) do
    def initialize(target, target_value) = super; end
  end

  class LEA < Struct.new('LEA', :target, :destination) do
    def initialize(target, destination) = super; end
  end

  class STOP < Struct.new('STOP', :value) do
    def initialize(value) = super; end
  end

  class MOVE < Struct.new('MOVE', :target, :destination, :target_size) do
    def initialize(target, destination, target_size) = super; end
  end

  class ANDI < Struct.new('ANDI', :target, :destination, :target_size) do
    def initialize(target, destination, target_size) = super; end
  end

  # Bcc instructions' target_size is SHORT (byte inside the instruction word) or WORD
  class BNE < Struct.new('BNE', :target, :target_size) do
    def initialize(target, target_size) = super; end
  end

  class BEQ < Struct.new('BEQ', :target, :target_size) do
    def initialize(target, target_size) = super; end
  end

  class BSR < Struct.new('BSR', :target, :target_size) do
    def initialize(target, target_size) = super; end
  end
end
