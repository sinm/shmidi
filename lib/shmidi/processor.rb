# coding: utf-8
module Shmidi
  class Processor
    attr_reader :app, :dev

    def initialize(indeces)
      @queue = Queue.new
      @app = Socket.new(:APP, indeces[0], indeces[1], @queue)
      @dev = Socket.new(:DEV, indeces[2], indeces[3], @queue)
      start
    end

    def start
      @processing ||= Thread.new do
        begin
          loop do
            event = @queue.pop
            Shmidi.TRACE("< #{event.source}\t#{event}")
          end
        rescue
          $stderr.puts($!)
          $stderr.puts($!.backtrace)
        end
      end
    end

    def join
      @processing.join if @processing
    end
  end
end