# coding: utf-8
module Shmidi
  class Knob < Control
    CTYPE = :KNO
    attr_reader :value

    def initialize(socket, channel, note, value = 0)
      super(socket, channel, note)
      init(value)
    end

    def init(value = 0)
      @prev_value = value
      @value = value
      @__on_value = []
      socket.on_event(channel, :cc, note) do |event|
        reset(event.value)
        Shmidi.TRACE("#{CTYPE}\t#{id}\t#{@value}")
        @__on_value.each { |b| b.call(self) }
      end
    end

    def reset(new_value=0)
      @prev_value = @value
      @value = 0
    end

    def on_value(&block)
      @__on_value << block
    end
  end
end
