require 'minitest/autorun'

require_relative './test_helper'

require 'target'


describe Target do
  describe Target::Immediate do
    it 'represents an immediate data' do
      assert_equal 0x0123, Target::Immediate.new(0x0123).data
    end
  end
end
