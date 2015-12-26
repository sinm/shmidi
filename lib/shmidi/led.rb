# coding: utf-8
module Shmidi
  class Led < Control
    attr_accessor :color #optional, dont care

    def initialize(id, socket, channel, note)
      super(id, socket, channel, note)
      @turned_on = false
      @turn_on_event = Event.new_on(@channel, @note)
      @turn_off_event = Event.new_off(@channel, @note)
    end

    def turned_on?
      !!@turned_on
    end

    def turn_on(clock = nil)
      if clock
        clock.sync(@turn_on_event)
      else
        @socket.push(@turn_on_event)
      end
      Shmidi.TRACE_INTERNAL("LED\t#{@id}\tON")
    end

    def turned_off?
      !@turned_on
    end

    def turn_off(clock = nil)
      if clock
        clock.sync(@turn_off_event)
      else
        @socket.push(@turn_off_event)
      end
      Shmidi.TRACE_INTERNAL("LED\t#{@id}\tOFF")
    end

  end
end
