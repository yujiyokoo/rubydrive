class Target
  class Absolute < Struct.new('Absolute', :address)
  end

  class Displacement < Struct.new('Displacement', :value)
  end
end
