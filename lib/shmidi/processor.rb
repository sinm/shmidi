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
        loop do
          begin
            event = @queue.pop
            Shmidi.TRACE_EXTERNAL("< #{event.source}\t#{event}")
          rescue
            Shmidi.ON_EXCEPTION
          end
        end
      end
    end

    def join
      @processing.join if @processing
    end
  end
end
