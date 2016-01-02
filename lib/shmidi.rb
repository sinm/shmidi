# coding: utf-8
require 'shmidi/version'

require 'timeout'

require 'unimidi'
require 'shmidi/ffi-coremidi-patch'

module Shmidi
  PROFILE         = !!ENV['PROFILE']
  TRACE           = !!ENV['TRACE']
  TRACE_EXTERNAL  = !!ENV['TRACE_EXTERNAL']
  TRACE_INTERNAL  = !!ENV['TRACE_INTERNAL'] # for leds

  def self.timestamp
    t = Time.now
    (t.to_i * 1000) + (t.usec / 1000)
  end

  # @@timestamp = timestamp
  # @@timestamp_thread = Thread.new do
  #   loop do
  #     @@timestamp = timestamp
  #     sleep(0.0005)
  #   end
  # end

  @@trace_queue = Queue.new
  @@trace_thread = Thread.new do
    loop do
      begin
        str = @@trace_queue.pop
        $stderr.puts("#{timestamp}\t#{str}")
      rescue
        $stderr.puts("Error in trace thread: #{$!}")
      end
    end
  end

  def self.TRACE(str)
    return nil unless TRACE
    @@trace_queue.push(str)
  end

  def self.TRACE_EXTERNAL(str)
    return nil unless TRACE_EXTERNAL
    @@trace_queue.push(str)
  end

  def self.TRACE_INTERNAL(str)
    return nil unless TRACE_INTERNAL
    @@trace_queue.push(str)
  end

  def self.ON_EXCEPTION
    back = $!.backtrace.join("\n\t\t")
    @@trace_queue.push("ERROR\t#{$!.class.name}:#{$!}\n\t\t#{back}")
  end
end

require 'shmidi/socket'
require 'shmidi/event'
require 'shmidi/processor'
require 'shmidi/notes'

require 'shmidi/clock'
  require 'shmidi/on_off_clock'

require 'shmidi/control'
  require 'shmidi/led'
  require 'shmidi/knob'
    require 'shmidi/fader'
    require 'shmidi/encoder'
  require 'shmidi/button'
    require 'shmidi/encoder_button'
    require 'shmidi/led_button'
      require 'shmidi/switch'
      require 'shmidi/retain_button'


