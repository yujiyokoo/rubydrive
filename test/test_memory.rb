require 'minitest/autorun'

require_relative './test_helper'

require 'memory'
require 'rom'
require 'controller_io'

describe Memory do
  describe 'with ROM and ControllerIO' do
    let(:rom) { Rom.new([0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]) }
    let(:controller_io) { ControllerIO.new(0xFFFFFFFF) }
    let(:memory) { Memory.new(rom: rom, controller_io: controller_io) }

    describe '#initialize' do
      it 'saves ROM and ControllerIO' do
        assert_equal rom, memory.rom
        assert_equal controller_io, memory.controller_io
      end

      it 'raises error if ROM is bigger than 0x3FFFFF' do
        assert_raises (RomSizeTooLarge) do
          Memory.new(rom: Rom.new([0x00] * 0x400000), controller_io: controller_io)
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
  end
end
