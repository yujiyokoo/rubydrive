require 'minitest/autorun'

require_relative './test_helper'
require 'm68k'
require 'rom'
require 'decoder'

describe M68k do
  let(:rom_contents) { [0x4E, 0x71, 0xFF, 0xFF] }
  let(:memory) { Rom.new(rom_contents) }
  let(:decoder) { Decoder.new }

  describe '#initialize' do
    it 'sets memory' do
      assert_equal memory, M68k.new(memory, decoder).memory
    end

    it 'sets PC to 0' do
      assert_equal 0, M68k.new(memory, decoder).pc
    end
  end

  describe '#next_instruction' do
    it 'returns the content at PC' do
      # 0x4E71 is NOP
      assert_equal :nop, M68k.new(memory, decoder).next_instruction
    end

    it 'advances the PC by instruction size' do
      m68k = M68k.new(memory, decoder)
      m68k.next_instruction
      assert_equal 2, m68k.pc # currently hardcoded to WORD size
    end
  end

  describe '#execute' do
  end
end
