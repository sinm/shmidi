# coding: utf-8
module Shmidi
  class Button < Control
    CTYPE = :BUT

    attr_reader :counter

    def initialize(socket, channel, note, pressed = false)
      super(socket, channel, note)
      @pressed = pressed
      init
    end

    def init
      @counter = 0
      @__on_press = []
      socket.on_event(channel, :on, note) do |event|
        @pressed = true
        @counter += 1 # intentionaly before handlers
        Shmidi.TRACE("#{CTYPE}\t#{id}\tPRESSED\t#{event.value}")
        @__on_press.each { |b| b.call(self) }
      end

      @on_release = []
      socket.on_event(channel, :off, note) do |event|
        @pressed = false
        Shmidi.TRACE("#{CTYPE}\t#{id}\tRELEASE\t#{event.value}")
        @on_release.each { |b| b.call(self) }
        @counter += 1 # intentionaly after handlers
      end
    end

    def reset
      @pressed = false
    end

    def pressed?
      !!@pressed
    end
    def on_press(&block)
      @__on_press << block
    end

    def released?
      !@pressed
    end
    def on_release(&block)
      @on_release << block
    end

  end
end
