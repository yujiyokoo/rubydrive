require 'minitest/autorun'

require_relative './test_helper'

require 'target'


describe Target do
  describe Target::AbsoluteLong do
    it 'represents an absolute long-word address' do
      assert_equal 0x01234567, Target::AbsoluteLong.new(0x01234567).address
    end
  end

  describe Target::AddrDisplacement do
    it 'represents displacement' do
      assert_equal 0x03, Target::AddrDisplacement.new(0x03).value
    end

    it 'represents negative displacement' do
      assert_equal(-0x03, Target::AddrDisplacement.new(-0x03).value)
    end
  end
end
