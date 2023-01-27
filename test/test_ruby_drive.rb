require 'minitest/autorun'

require_relative './test_helper'
require 'ruby_drive'

describe RubyDrive do
  let(:fake_m68k) {
    Struct.new(:next_instruction, :running) do
      def running?
        running
      end
      def execute(_instruction)
        raise "execute called"
      end
    end
  }
  let(:m68k) { fake_m68k.new(:inst, :false) }
  let(:rd) { RubyDrive.new(m68k) }

  describe '#step' do
    it 'gets next instruction from m68k' do
      assert_equal rd.step, :inst
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
