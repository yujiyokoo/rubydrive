require 'minitest/autorun'

require_relative './test_helper'
require 'm68k'
require 'rom'
require 'decoder'
require 'instruction'
require 'memory'
require 'controller_io'
require 'target'

describe M68k do
  let(:rom_contents) { [0xff, 0xff, 0x00, 0xfe, 0x00, 0x00, 0x00, 0x08, 0x4E, 0x71] }
  let(:rom) { Rom.new(rom_contents) }
  let(:memory) { Memory.new(rom: rom, controller_io: ControllerIO.new(0x00000000)) }
  let(:decoder) { Decoder.new }

  describe '#initialize' do
    it 'sets memory' do
      assert_equal memory, M68k.new(memory, decoder).memory
    end

    it 'sets SP to the first lonng word' do
      assert_equal 0xffff00fe, M68k.new(memory, decoder).sp
    end

    it 'sets PC to the second long word' do
      assert_equal 0x00000008, M68k.new(memory, decoder).pc
    end
  end

  describe '#next_instruction' do
    it 'returns the content at PC' do
      # 0x4E71 is NOP
      assert_equal Instruction::NOP.new, M68k.new(memory, decoder).next_instruction
    end

    it 'advances the PC by instruction size' do
      m68k = M68k.new(memory, decoder)
      assert_equal 8, m68k.pc
      m68k.next_instruction
      assert_equal 10, m68k.pc # currently hardcoded to WORD size
    end
  end

  describe '#execute' do
    let(:m68k) { M68k.new(memory, decoder) }

    describe 'NOP' do
      it 'does not cause unsupported instruction error' do
        assert_nil m68k.execute(Instruction::NOP.new)
      end
    end

    describe 'MOVE_TO_SR' do
      it 'copies a word to SR' do
        m68k.execute(Instruction::MOVE_TO_SR.new(0xFECD))
        assert_equal 0xCD, m68k.sr
      end
    end

    describe 'TST' do
      it 'sets V and C flags 0' do
        m68k.execute(Instruction::TST.new(Target::Absolute.new(0x00a10008), LONGWORD_SIZE))
        assert_equal 0b00, m68k.sr & 0x03
      end

      it 'checks abusolute long word address and sets Z if zero' do
        m68k.sr = 0
        m68k.execute(Instruction::TST.new(Target::Absolute.new(0x00a10008), LONGWORD_SIZE))
        assert_equal 0b01, (m68k.sr & 0x0C) >> 2 # Z is set, N is not set
      end

      it 'checks abusolute long word address and sets N if negative' do
        m68k.memory = Memory.new(rom: rom, controller_io: ControllerIO.new(0xFFFFFFFF))
        m68k.sr = 0
        m68k.execute(Instruction::TST.new(Target::Absolute.new(0x00a10008), LONGWORD_SIZE))
        assert_equal 0b10, (m68k.sr & 0x0C) >> 2 # Z is not set, N is set
      end
    end

    describe 'others' do
      it 'causes unsupported instruction error' do
        assert_raises(UnsupportedInstruction) do
          m68k.execute(nil)
        end
      end
    end
  end
end
