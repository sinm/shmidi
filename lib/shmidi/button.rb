# coding: utf-8
module Shmidi
  class Button < Control
    attr_reader :counter

    def initialize(id, socket, channel, note)
      super(id, socket, channel, note)

      @pressed = false
      @counter = 0

      @on_press = []
      socket.on_event(channel, :on, note) do |event|
        @pressed = true
        @counter += 1 # intentionaly before handlers
        Shmidi.TRACE("BTN\t#{@id}\tPRESSED")
        @on_press.each { |b| b.call(self) }
      end

      @on_release = []
      socket.on_event(channel, :off, note) do |event|
        @pressed = false
        #TODO: why it is not on the screen!!!
        Shmidi.TRACE("BTN\t#{@id}\tRELEASED")
        @on_release.each { |b| b.call(self) }
        @counter += 1 # intentionaly after handlers
      end
    end

    def pressed?
      !!@pressed
    end
    def on_press(&block)
      @on_press << block
    end

    def released?
      !@pressed
    end
    def on_release(&block)
      @on_release << block
    end

  end
end
