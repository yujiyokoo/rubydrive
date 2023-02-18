require 'minitest/autorun'

require_relative './test_helper'

require 'memory'
require 'rom'
require 'ram'
require 'controller_io'

describe Memory do
  describe 'with ROM and ControllerIO' do
    let(:rom) { Rom.new([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]) }
    let(:controller_io) { ControllerIO.new(0xFFFFFFFF) }
    let(:ram) { Ram.new }
    let(:memory) { Memory.new(rom: rom, controller_io: controller_io, ram: ram) }

    describe '#initialize' do
      it 'saves ROM, ControllerIO and RAM' do
        assert_equal rom, memory.rom, ram
        assert_equal controller_io, memory.controller_io
        assert_equal ram, memory.ram
      end

      it 'raises error if ROM is bigger than 0x3FFFFF' do
        assert_raises (RomSizeTooLarge) do
          Memory.new(rom: Rom.new([0x00] * 0x400000), controller_io: controller_io, ram: ram)
        end
      end
    end

    describe '#initial_sp' do
      it 'returns the first 4 bytes of ROM' do
        assert_equal 0x01020304, memory.initial_sp
      end
    end

    describe '#initial_pc' do
      it 'returns the 5th-8th bytes of ROM' do
        assert_equal 0x05060708, memory.initial_pc
      end
    end

    it 'reads a word from ROM' do
      assert_equal 0x0102, memory.get_word(0)
    end

    it 'reads a word from ControllerIO' do
      assert_equal 0xFFFF, memory.get_word(0xA10000)
    end

    describe '#write_long_word' do
      it 'writes a long word at address' do
        memory.write_long_word(0xFF0000, 0x53454741)
        assert_equal 0x53454741, memory.get_long_word(0xFF0000)
      end

      it 'raises an error when attempting to write to rom' do
        assert_raises(InvalidAddress) do
          memory.write_long_word(0, 0x53544741)
        end
      end

      it 'raises an error if address is out of range' do
        assert_raises(InvalidAddress) do
          memory.write_long_word(0x1000000, 0x53454741)
        end
      end
    end
  end
end
