# coding: utf-8
module Shmidi
  class Knob < Control
    CTYPE = :KNO
    attr_reader :value

    def initialize(id, socket, channel, note, value = 0)
      super(id, socket, channel, note)
      @prev_value = value
      @value = value
      @on_value = []
      socket.on_event(channel, :cc, note) do |event|
        @prev_value = @value
        @value = event.value
        Shmidi.TRACE("#{CTYPE}\t#{@id}\t#{direction}\t#{@value}")
        @on_value.each { |b| b.call(self) }
      end
    end

    def direction
      @prev_value > @value ? :DOWN : :UP
    end

    def on_value(&block)
      @on_value << block
    end
  end
end
