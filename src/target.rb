class Target
  class Absolute < Struct.new('Absolute', :address)
  end

  class AddrDisplacement < Struct.new('AddrDisplacement', :value)
  end

  class PcDisplacement < Struct.new('PcDisplacement', :value)
  end

  class Register < Struct.new('Register', :name)
  end
end
