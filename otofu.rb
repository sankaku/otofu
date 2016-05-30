#!/usr/bin/env ruby
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'lib/file_converter.rb'

input_file = ARGV[0]
converter = FileConverter.new(input_file)
converter.convert
