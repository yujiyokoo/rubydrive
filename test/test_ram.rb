require 'minitest/autorun'

require_relative './test_helper'

require 'ram'

describe Ram do
  describe '#initialize' do
    it 'builds contents array' do
      ram = Ram.new
      assert_equal 0, ram.contents[0]
      assert_equal 0x10000, ram.contents.size
    end
  end

  describe '#copy_long_word' do
   it 'copies 4 bytes to addr - 0xFF000000' do
      ram = Ram.new
      ram.copy_long_word(0xFF0002, 0x11111111)
      assert_equal 0x11, ram.contents[2]
    end

    it 'raises address error if odd address accessed' do
      ram = Ram.new
      assert_raises(AddressError) do
        ram.copy_long_word(0xFF0001, 0x11111111)
      end
    end

    it 'raises bus error if end of address space reached' do
      ram = Ram.new
      assert_raises(BusError) do
        ram.copy_long_word(0xFFFFFE, 0x11111111)
      end
    end
  end

  describe '#copy_word' do
   it 'copies 4 bytes to addr - 0xFF000000' do
      ram = Ram.new
      ram.copy_word(0xFF0002, 0x1111)
      assert_equal 0x11, ram.contents[2]
    end

    it 'raises address error if odd address accessed' do
      ram = Ram.new
      assert_raises(AddressError) do
        ram.copy_word(0xFF0001, 0x1111)
      end
    end

    it 'raises bus error if end of address space reached' do
      ram = Ram.new
      assert_raises(BusError) do
        ram.copy_word(0x1000000, 0x1111)
      end
    end
  end

  describe '#get_long_word' do
    it 'reads 4 bytes from addr' do
      ram = Ram.new
      ram.contents[0] = 0xAB
      ram.contents[1] = 0xCD
      val = ram.get_long_word(0xFF0000)
      assert_equal 0xABCD0000, val
    end

    it 'raises address error if odd address accessed' do
      ram = Ram.new
      assert_raises(AddressError) do
        ram.get_long_word(0xFF0001)
      end
    end

    it 'raises bus error if end of address space reached' do
      ram = Ram.new
      assert_raises(BusError) do
        ram.get_long_word(0xFFFFFE)
      end
    end
  end

  describe '#get_word' do
    it 'reads 4 bytes from addr' do
      ram = Ram.new
      ram.contents[0] = 0xAB
      ram.contents[1] = 0xCD
      val = ram.get_word(0xFF0000)
      assert_equal 0xABCD, val
    end

    it 'raises address error if odd address accessed' do
      ram = Ram.new
      assert_raises(AddressError) do
        ram.get_word(0xFF0001)
      end
    end

    it 'raises bus error if end of address space reached' do
      ram = Ram.new
      assert_raises(BusError) do
        ram.get_word(0x1000000)
      end
    end
  end
end
