require 'minitest/autorun'
require_relative './test_helper'

require 'ruby_drive'
require 'm68k'
require 'rom'
require 'decoder'
require 'memory'
require 'controller_io'

describe 'integration' do
  let(:two_nops) { [0xff, 0xff, 0x00, 0xfe, 0x00, 0x00, 0x00, 0x08, 0x4E, 0x71, 0x4E, 0x71] }

  it 'loads and executes NOPs' do
    memory = Memory.new(rom: Rom.new(two_nops), controller_io: ControllerIO.new(0x00000000), ram: Ram.new, tmss: Tmss.new)
    rd = RubyDrive.new(M68k.new(memory, Decoder.new))

    assert_raises(BusError) do
      rd.run
    end
    assert_equal 12, rd.m68k.pc
  end
end
