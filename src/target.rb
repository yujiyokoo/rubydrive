class Target
  class AbsoluteLong < Struct.new('AbsoluteLong', :address)
  end

  class AddrDisplacement < Struct.new('AddrDisplacement', :value)
  end

  class PcDisplacement < Struct.new('PcDisplacement', :value)
  end

  class Register < Struct.new('Register', :name)
  end

  class Immediate < Struct.new('Immediate', :value)
  end

  class RegisterIndirect < Struct.new('RegisterIndirect', :name, :post_increment)
  end
end
