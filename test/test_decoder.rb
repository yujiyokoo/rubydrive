require 'minitest/autorun'

require_relative './test_helper'

require 'decoder'
require 'rom'

describe Decoder do
  let(:decoder) { Decoder.new }
  describe "#get_instruction" do
    it "returns NOP for 0x4E71" do
      memory = Rom.new([0x4E, 0x71])
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal Instruction::NOP.new, instruction
    end

    it "returns 'MOVE_TO_SR' for 0x46fc2700" do
      memory = Rom.new([0x46, 0xFC, 0x27, 0x00])
      move_to_sr = Instruction::MOVE_TO_SR.new(0x2700) # move 0x2700 word to SR
      instruction, mv = decoder.get_instruction(memory, 0)
      assert_equal move_to_sr, instruction
      assert_equal 4, mv # advance by long-word size
    end
  end
end
