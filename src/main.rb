#!/usr/bin/env ruby

$:.push('.')
$:.push('src')

require 'm68k'
require 'rom'
require 'ruby_drive'

require 'pp'

puts "starting rubydrive..."

rom_file = open(ARGV[0], 'rb') do |binfile|
  bin = binfile.read
  ary = bin.unpack('c*')
end

memory = Rom.new(rom_file)
decoder = Decoder.new

RubyDrive.new(M68k.new(memory, decoder)).run

