require 'minitest/autorun'

require_relative './test_helper'

require 'decoder'
require 'rom'

describe Decoder do
  let(:decoder) { Decoder.new }
  describe "#get_instruction" do
    it "returns NOP for 0x4E71" do
      memory = Rom.new([0x4E, 0x71])
      instruction, _ = decoder.get_instruction(memory, 0)
      assert_equal Instruction::NOP.new, instruction
    end

    it "returns 'MOVE_TO_SR' for 0x46fc2700" do
      memory = Rom.new([0x46, 0xFC, 0x27, 0x00])
      move_to_sr = Instruction::MOVE_TO_SR.new(0x2700) # move 0x2700 word to SR
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal move_to_sr, instruction
      assert_equal 4, mv # advance by long-word size
    end

    it "returns TST.l, absolute long for 4a b9 00 a1 00 08" do
      memory = Rom.new([0x4a, 0xb9, 0x00, 0xa1, 0x00, 0x08])
      tstl = Instruction::TST.new(Target::Absolute.new(0x00a10008), LONGWORD_SIZE)
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal tstl, instruction
      assert_equal 6, mv # advance by word + long-word
    end

    it "returns TST.w, absolute long for 4a 79 00 a1 00 0c" do
      memory = Rom.new([0x4a, 0x79, 0x00, 0xa1, 0x00, 0x0c])
      tstl = Instruction::TST.new(Target::Absolute.new(0x00a1000c), WORD_SIZE)
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal tstl, instruction
      assert_equal 6, mv # advance by word + long-word
    end

    # NOTE: the disassembled code seems to go from 20a to 212 when jumping by 6
    # That must be PC is 20c when 6 is added...
    it "returns BNE.s, by 6 for 6606" do
      memory = Rom.new([0x66, 0x06, 0x00, 0x00])
      expected = Instruction::BNE.new(Target::AddrDisplacement.new(0x06), SHORT_SIZE)
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal expected, instruction
      assert_equal 2, mv
    end

    it "returns LEA, PC + PC(displacement), into a5 for 4b fa 00 34" do
      memory = Rom.new([0x4b, 0xfa, 0x00, 0x34])
      expected = Instruction::LEA.new(Target::PcDisplacement.new(0x34), :a5)
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal expected, instruction
      assert_equal 4, mv
    end

    it "returns LEA, PC + PC(displacement), into a4 for 49 fa 00 34" do
      memory = Rom.new([0x49, 0xfa, 0x00, 0x34])
      expected = Instruction::LEA.new(Target::PcDisplacement.new(0x34), :a4)
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal expected, instruction
      assert_equal 4, mv
    end

    it "returns STOP with WORD for 4e 72 27 00" do
      memory = Rom.new([0x4e, 0x72, 0x27, 0x00])
      expected = Instruction::STOP.new(0x2700)
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal expected, instruction
      assert_equal 4, mv
    end
  end
end
