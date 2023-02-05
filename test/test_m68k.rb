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

    it 'sets SP to the first long word (which is a7 register)' do
      assert_equal 0xffff00fe, M68k.new(memory, decoder).sp
      assert_equal 0xffff00fe, M68k.new(memory, decoder).registers[:a7]
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

    describe 'MOVE' do
      let(:memory) { Memory.new(rom: Rom.new([0, 0, 0, 0, 0, 0, 0, 0]), controller_io: ControllerIO.new(0x01234567)) }

      it 'copies a byte only for MOVE.b, absolute, long, data reg' do
        m68k.registers[:d0] = 0xFFFF
        m68k.execute(Instruction::MOVE.new(Target::Absolute.new(0x00a10001), Target::Register.new(:d0), BYTE_SIZE))
        assert_equal 0xFF67, m68k.registers[:d0] # only the lowest byte is copied
      end
    end

    describe 'TST' do
      it 'sets V and C flags 0' do
        m68k.execute(Instruction::TST.new(Target::Absolute.new(0x00a10008), LONGWORD_SIZE))
        assert_equal 0b00, m68k.sr & 0x03
      end

      it 'checks long word at abusolute long word address and sets Z if zero' do
        m68k.sr = 0
        m68k.execute(Instruction::TST.new(Target::Absolute.new(0x00a10008), LONGWORD_SIZE))
        assert_equal 0b01, (m68k.sr & 0x0C) >> 2 # Z is set, N is not set
      end

      it 'checks long word at abusolute long word address and sets N if negative' do
        m68k.memory = Memory.new(rom: rom, controller_io: ControllerIO.new(0xFFFFFFFF))
        m68k.sr = 0
        m68k.execute(Instruction::TST.new(Target::Absolute.new(0x00a10008), LONGWORD_SIZE))
        assert_equal 0b10, (m68k.sr & 0x0C) >> 2 # Z is not set, N is set
      end

      it 'checks word at abusolute long word address and sets Z if zero' do
        m68k.memory = Memory.new(rom: rom, controller_io: ControllerIO.new(0xFFFF0000))
        m68k.sr = 0
        m68k.execute(Instruction::TST.new(Target::Absolute.new(0x00a10008), WORD_SIZE))
        assert_equal 0b01, (m68k.sr & 0x0C) >> 2 # Z is set, N is not set
      end

      it 'checks word at abusolute long word address and sets N if negative' do
        m68k.memory = Memory.new(rom: rom, controller_io: ControllerIO.new(0x0000FFFF))
        m68k.sr = 0
        m68k.execute(Instruction::TST.new(Target::Absolute.new(0x00a10008), WORD_SIZE))
        assert_equal 0b10, (m68k.sr & 0x0C) >> 2 # Z is not set, N is set
      end
    end

    describe 'BNE' do
      # Note this moves PC by 6 and 'step' moves the PC by 2...
      # should they be combined into one method?
      it 'updates PC by 6 for 0x6606 if Z flag is 0' do
        m68k.pc = 2
        m68k.sr = 0x0B
        instruction = Instruction::BNE.new(Target::AddrDisplacement.new(0x06), SHORT_SIZE)
        m68k.execute(instruction)
        assert_equal 0x08, m68k.pc
      end
    end

    describe 'BEQ' do
      it 'updates PC by 0a (for 0x670a) if Z flag is 1' do
        m68k.pc = 2
        m68k.sr = 0x04
        instruction = Instruction::BEQ.new(Target::AddrDisplacement.new(0x0a), SHORT_SIZE)
        m68k.execute(instruction)
        assert_equal 0x0C, m68k.pc
      end
    end

    describe 'LEA' do
      it 'adds content at (PC+displacement) and stores it in register' do
        m68k.pc = 0xFF
        instruction = Instruction::LEA.new(Target::PcDisplacement.new(0x04), :a5)
        m68k.execute(instruction)
        assert_equal 0x107, m68k.registers[:a5]
      end
    end

    describe 'STOP' do
      it 'copies the parameter to SR register and stops processor' do
        m68k.sr = 0x00
        m68k.running = true
        instruction = Instruction::STOP.new(0xC4)
        m68k.execute(instruction)
        assert_equal 0xC4, m68k.sr
        assert !m68k.running?
      end
    end

    describe 'ANDI' do
      it 'does AND with immediate data and puts the result in the register' do
        m68k.registers[:d1] = 0xFFF0
        instruction = Instruction::ANDI.new(Target::Immediate.new(0xAA), Target::Register.new(:d1), BYTE_SIZE)
        m68k.execute(instruction)
        assert_equal 0xFFA0, m68k.registers[:d1]
      end

      it 'sets V and C flags to zero' do
        m68k.sr = 0xFFFFFFFF
        m68k.registers[:d1] = 0xFFF0
        instruction = Instruction::ANDI.new(Target::Immediate.new(0xAA), Target::Register.new(:d1), BYTE_SIZE)
        m68k.execute(instruction)
        assert_equal 0, m68k.sr & 0x03
      end

      it 'sets N if negative' do
        m68k.sr = 0xFFFFFF00
        m68k.registers[:d1] = 0xFFFF
        instruction = Instruction::ANDI.new(Target::Immediate.new(0xAA), Target::Register.new(:d1), BYTE_SIZE)
        m68k.execute(instruction)
        assert_equal 0x04, m68k.sr & 0x0F
      end

      it 'sets Z if zero' do
        m68k.sr = 0xFFFFFF00
        m68k.registers[:d1] = 0x0000
        instruction = Instruction::ANDI.new(Target::Immediate.new(0xAA), Target::Register.new(:d1), BYTE_SIZE)
        m68k.execute(instruction)
        assert_equal 0x08, m68k.sr & 0x0F
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
