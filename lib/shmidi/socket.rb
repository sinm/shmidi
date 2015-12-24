# coding: utf-8
module Shmidi
  class Socket
    attr_reader :name

    def initialize(name, in_id, out_id, queue)
      @in   = UniMIDI::Input.all.find { |d| d.id == in_id  }
      @out  = UniMIDI::Output.all.find{ |d| d.id == out_id }
      @name = name
      @queue = queue
      @listener = Thread.new do
        begin
          loop do
            @in.gets.each do |e|
              e[:source] = @name
              @queue.push(Event.new(e))
            end
          end
        rescue
          $stderr.puts($!)
          $stderr.puts($!.backtrace)
        end
      end
    end

    def push(events)
      events = Array(events)
      #$stderr.puts events.inspect
      events = events.reduce([]) do |array, event|
        $stderr.puts("> #{@name}\t#{event}") if TRACE
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
