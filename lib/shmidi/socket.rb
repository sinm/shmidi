# coding: utf-8
module Shmidi
  class Socket
    attr_reader :name

    def initialize(name, in_id, out_id, queue)
      @in   = UniMIDI::Input.all.find { |d| d.id == in_id  }
      @out  = UniMIDI::Output.all.find{ |d| d.id == out_id }
      @name = name
      @queue = queue
      @on_event = []
      @sync_threads = Hash.new { |hash, key| hash[key] = Clock.new(key, self) }
      @listener = Thread.new do
        begin
          loop do
            @in.gets.each do |event|
              event[:source] = @name
              event = Event.new(event)
              @queue.push(event)
              @on_event.each do |rule|
                #puts rule.inspect #!!!!!!!!!!!!!!!!!!
                next if (channel  = rule[:channel]) && channel  != event.channel
                next if (message  = rule[:message]) && message  != event.message
                next if (note     = rule[:note])    && note     != event.note

                rule[:block].call(event)
              end
            end
          end
        rescue
          $stderr.puts($!)
          $stderr.puts($!.backtrace)
        end
      end
    end

    def on_event(channel = nil, message = nil, note = nil, &block)
      @on_event << {
        :block => block,
        :channel => channel,
        :message => message,
        :note => note
      }
    end

    def push(events)
      events = Array(events).reduce([]) do |array, event|
        Shmidi.TRACE("> #{@name}\t#{event}")
        array << event.data
        array
      end
      @out.puts(*events)
    end

    def self.print_device_list
      $stdout.puts('Inputs:')
      UniMIDI::Input.list
      $stdout.puts('Outputs:')
      UniMIDI::Output.list
    end
  end
end
