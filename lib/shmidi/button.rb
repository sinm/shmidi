# coding: utf-8
module Shmidi
  class Button < Control
    attr_accessor :id # NOTE: may be array kind of [row, column]
    attr_accessor :name # optional name, don't bother for now

    def initialize(id, socket, channel, note)
      @id = id
      @pressed = false

      @on_pressed = []
      socket.on_event(channel, :on, note) do |event|
        @pressed = true
        Shmidi.TRACE("BTN\t#{id}\tPRESSED")
        @on_pressed.each { |b| b.call(self) }
      end

      @on_released = []
      socket.on_event(channel, :off, note) do |event|
        @pressed = false
        #TODO: why it is not on the screen!!!
        Shmidi.TRACE("BTN\t#{id}\tRELEASED")
        @on_released.each { |b| b.call(self) }
      end
    end

    def pressed?
      @pressed
    end
    def on_pressed(&block)
      @on_pressed << block
    end

    def released?
      !@pressed
    end
    def on_released(&block)
      @on_released << block
    end

  end
end
