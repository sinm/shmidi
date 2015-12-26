# coding: utf-8
module Shmidi
  class OnOffClock < Clock
    def initialize(socket, delay = 0.05, delay_off = 0.25)
      @next_on = false
      super(socket, delay)
      @delay_off = delay_off
    end

    protected

    def filter
      b = @buffer
      @buffer = []
      bb = b.select { |e| e.message == (@next_on ? :on : :off) }
      b = b - bb
      @buffer = @buffer + b
      bb
    end

    def wait
      d = @next_on ? @delay : @delay_off
      @next_on = !@next_on
      sleep(d)
    end
  end
end
