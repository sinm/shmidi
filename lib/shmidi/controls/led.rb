# coding: utf-8
module Shmidi
  class Led < Control
    CTYPE = :LED

    def initialize(socket, channel, note, turned_on = false)
      super(socket, channel, note)
      init(turned_on)
    end

    def init(turned_on = false)
      @turned_on = false
      @__turn_on_event = Event.new_on(@channel, @note)
      @__turn_off_event = Event.new_off(@channel, @note)
      turn_on if turned_on
    end

    def reset
      turn_off
    end

    def on?
      !!@turned_on
    end

    def turn_on(clock = nil)
      (clock && clock.sync(@__turn_on_event)) || socket.push(@__turn_on_event)
      @turned_on = true
    end

    def turn_off(clock = nil)
      (clock && clock.sync(@__turn_off_event)) || socket.push(@__turn_off_event)
      @turned_on = false
    end

  end
end
