require 'minitest/autorun'

require_relative './test_helper'

require 'target'


describe Target do
  describe Target::Absolute do
    it 'represents an absolute long-word address' do
      assert_equal 0x01234567, Target::Absolute.new(0x01234567).address
    end
  end

  describe Target::Displacement do
    it 'represents displacement' do
      assert_equal 0x03, Target::Absolute.new(0x03).address
    end

    it 'represents negative displacement' do
      assert_equal(-0x03, Target::Absolute.new(-0x03).address)
    end
  end
end
