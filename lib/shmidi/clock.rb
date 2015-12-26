module Shmidi
  class Event
    attr_accessor :destination
  end

  class Clock
    def initialize(socket, delay = 0.25)
      @socket = socket
      @delay = delay
      @thread = Thread.new do
        loop do
          begin
            buf = @buffer
            @buffer = []
            @socket.push(buf)
            buf.each do |event|
              event.destination.push(true)
            end
            sleep(@delay)
          rescue
            $stderr.puts($!)
            $stderr.puts($!.backtrace)
          end
        end
      end
    end

    def sync(event)
      event.destination = Queue.new
      @buffer << event
      event.destination.pop
      $stderr.puts('synced!')
    end
  end
end
