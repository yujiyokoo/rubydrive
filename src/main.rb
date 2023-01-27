#!/usr/bin/env ruby

$:.push('.')
$:.push('src')

require 'm68k'
require 'rom'
require 'ruby_drive'

require 'pp'

puts "starting rubydrive..."

memory = Rom.new([0x4E, 0x71, 0xFF, 0xFF])
decoder = Decoder.new

RubyDrive.new(M68k.new(memory, decoder)).run

