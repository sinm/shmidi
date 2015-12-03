# coding: utf-8
begin
  require 'codeclimate-test-reporter'
  CodeClimate::TestReporter.start
rescue LoadError
  $stderr.puts "CodeClimate is not started: #{$!.message}"
end

require 'minitest/autorun'
require 'shmidi'

