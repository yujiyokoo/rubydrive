class Target
  class Absolute < Struct.new('Absolute', :address)
  end

  class AddrDisplacement < Struct.new('AddrDisplacement', :value)
  end

  class PcDisplacement < Struct.new('PcDisplacement', :value)
  end
end
