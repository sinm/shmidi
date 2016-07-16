# coding: utf-8
require 'shmidi/version'

require 'timeout'

require 'unimidi'
require 'shmidi/ffi-coremidi-patch'

module Shmidi
  PROFILE         = !!ENV['PROFILE']
  TRACE           = !!ENV['TRACE']
  TRACE_EXTERNAL  = !!ENV['TRACE_EXTERNAL']
  TRACE_INTERNAL  = !!ENV['TRACE_INTERNAL']

  def self.timestamp
    t = Time.now
    (t.to_i * 1000) + (t.usec / 1000)
  end

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

  require 'oj'
  JSON_CREATE_ID = 'm_type'
  ::Oj.default_options = {
    :mode         => :compat,
    :class_cache  => true,
    :create_id    => JSON_CREATE_ID,
    :time         => :unix
  }

  def self.DUMP(obj, opts={})
    Oj.dump((obj.kind_of?(Base) ? obj.to_hash : obj), opts)
  end

  def self.JSON_PARSE str, opts = {:warn => true}
    return nil if str.nil?
    Oj.load(str, opts)
  rescue
    if opts[:warn]
      Shmidi::ON_EXCEPTION
      TRACE "#{str}".force_encoding(Encoding::UTF_8)
    end
    nil
  end

  def self.PRETTY obj
    DUMP((obj.kind_of?(String) ? JSON_PARSE(obj) : obj), :indent=>2)
  end
end

require 'shmidi/base'

require 'shmidi/socket'
require 'shmidi/event'
require 'shmidi/controller'

require 'shmidi/clock'
  require 'shmidi/on_off_clock'

require 'shmidi/control'
  require 'shmidi/controls/led'
    require 'shmidi/composite/rgy_led'
  require 'shmidi/controls/knob'
    require 'shmidi/controls/fader'
    require 'shmidi/controls/encoder'
  require 'shmidi/controls/button'
    require 'shmidi/led_button'
      require 'shmidi/switch'


