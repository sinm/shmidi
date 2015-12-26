# coding: utf-8
require 'shmidi/version'

require 'timeout'

require 'unimidi'
require 'shmidi/ffi-coremidi-patch'

module Shmidi
  TRACE   = !!ENV['TRACE']
  PROFILE = !!ENV['PROFILE']

  def self.timestamp
    #TODO: timestamp
  end

  @@trace_queue = Queue.new
  @@trace_thread = Thread.new do
    begin
      loop do
        $stderr.puts(@@trace_queue.pop)
      end
    rescue
      $stderr.puts($!)
      $stderr.puts($!.backtrace)
    end
  end

  def self.TRACE(str)
    return nil unless TRACE
    @@trace_queue.push(str)
  end
end

require 'shmidi/socket'
require 'shmidi/event'
require 'shmidi/processor'
require 'shmidi/notes'

require 'shmidi/clock'
require 'shmidi/control'
require 'shmidi/button'
require 'shmidi/led'
require 'shmidi/led_button'
require 'shmidi/retain_button'

