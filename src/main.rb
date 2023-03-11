#!/usr/bin/env ruby

$:.push('.')
$:.push('src')

require 'm68k'
require 'rom'
require 'ram'
require 'memory'
require 'controller_io'
require 'tmss'
require 'vdp_registers'
require 'ruby_drive'

require 'pp'

puts "starting rubydrive..."

rom_file = open(ARGV[0], 'rb') do |binfile|
  bin = binfile.read
  ary = bin.unpack('c*')
end

memory = Memory.new(rom: Rom.new(rom_file), controller_io: ControllerIO.new(0xFFFFFFFF), ram: Ram.new, tmss: Tmss.new)
decoder = Decoder.new

RubyDrive.new(M68k.new(memory, decoder)).run

puts "rubydrive finished"
