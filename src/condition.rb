class Condition
  class False < Struct.new('False')
    def self.evaluate = false
  end
end
