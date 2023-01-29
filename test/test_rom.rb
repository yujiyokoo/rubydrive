require 'minitest/autorun'

require_relative './test_helper'
require 'rom'

describe Rom do
  describe '#initialize' do
    it 'sets initial rom value' do
      assert_equal [1, 2, 3, 4], Rom.new([1, 2, 3, 4]).contents
    end
  end

  describe '#get_byte' do
    it 'gets the byte from location' do
      assert_equal 0x03, Rom.new([1, 2, 3, 4]).get_byte(2)
    end

    it 'raises a bus error if address points to an odd location' do
      assert_raises(BusError) do
        Rom.new([1, 2, 3, 4]).get_byte(4)
      end
    end
  end

  describe '#get_word' do
    it 'gets the word from location' do
      assert_equal 0x0304, Rom.new([1, 2, 3, 4]).get_word(2)
    end

    it 'raises an address error if address points to an odd location' do
      assert_raises(AddressError) do
        Rom.new([1, 2, 3, 4]).get_word(1)
      end
    end

    it 'raises a bus error if address points to an odd location' do
      assert_raises(BusError) do
        Rom.new([1, 2, 3, 4]).get_word(4)
      end
    end
  end

  describe '#get_long_word' do
    it 'gets the word from location' do
      assert_equal 0x01020304, Rom.new([1, 2, 3, 4]).get_long_word(0)
    end

    it 'raises an address error if address points to an odd location' do
      assert_raises(AddressError) do
        Rom.new([1, 2, 3, 4]).get_long_word(1)
      end
    end

    it 'raises a bus error if address points to an odd location' do
      assert_raises(BusError) do
        Rom.new([1, 2, 3, 4]).get_long_word(2)
      end
    end
  end
end
