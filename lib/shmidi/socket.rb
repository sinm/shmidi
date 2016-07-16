# coding: utf-8
module Shmidi
  class Socket
    include Base

    @@controllers = {}
    def self.[](name)
      @@controllers[name]
    end

    attr_reader :name, :in, :out

    def initialize(name, in_id, out_id)
      @name = name
      @in = in_id
      @out = out_id
      init
    end

    def init
      @__in_dev   = UniMIDI::Input.all.find { |d| d.name == @in  }
      @__out_dev  = UniMIDI::Output.all.find { |d| d.name == @out }

      @@controllers[@name] = self
      @__queue = Queue.new
      @__on_event = []
      # @__sync_threads = Hash.new { |hash, key| hash[key] = Clock.new(key, self) }
      @__listener = Thread.new do
        loop do
          break unless @__in_dev
          begin
            @__in_dev.gets.each do |event|
              event[:source] = @name
              event = Event.new(event)
              Shmidi.TRACE_INTERNAL("> #{@name}\t#{event}")
              @__queue.push(event)
              @__on_event.each do |rule|
                next if (channel  = rule[:channel]) && channel  != event.channel
                next if (message  = rule[:message]) && message  != event.message
                next if (note     = rule[:note])    && note     != event.note
                next if (value    = rule[:value])   && value    != event.value

                rule[:block].call(event) rescue Shmidi.ON_EXCEPTION
              end
            end
          rescue
            Shmidi.ON_EXCEPTION
          end
        end
      end
    end

    def on_event(channel = nil, message = nil, note = nil, value = nil, &block)
      @__on_event << {
        :block => block,
        :channel => channel,
        :message => message,
        :note => note
      }
    end

    def push(events)
      events = Array(events).reduce([]) do |array, event|
        Shmidi.TRACE_EXTERNAL("< #{@name}\t#{event}")
        array << event.data
        array
      end
      @__out_dev.puts(*events)
    end

    def self.print_device_list
      $stdout.puts('Inputs:')
      UniMIDI::Input.list
      $stdout.puts('Outputs:')
      UniMIDI::Output.list
    end
  end
end
