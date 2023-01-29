require 'minitest/autorun'

require_relative './test_helper'

require 'target'


describe Target do
  describe Target::Absolute do
    it 'represents an absolute long-word address' do
      assert_equal 0x01234567, Target::Absolute.new(0x01234567).data
    end
  end
end
