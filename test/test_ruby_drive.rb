require 'minitest/autorun'

require_relative './test_helper'
require 'ruby_drive'

describe RubyDrive do
  let(:fake_m68k) {
    Struct.new(:current_instruction, :running) do
      def running?
        running
      end
      def execute(_instruction)
        raise "execute called"
      end
    end
  }
  let(:m68k) { fake_m68k.new([:inst, WORD_SIZE], :false) }
  let(:rd) { RubyDrive.new(m68k) }

  describe '#get_instruction' do
    it 'gets current instruction from m68k' do
      assert_equal rd.get_instruction, [:inst, WORD_SIZE]
    end
  end

  describe '#run' do
    it 'calls execute on m68k' do
      assert_raises(RuntimeError) do
        rd.run
      end
    end
  end
end
