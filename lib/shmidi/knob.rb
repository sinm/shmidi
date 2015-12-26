# coding: utf-8
module Shmidi
  attr_reader :value

  class Knob < Control
    def initialize(id, socket, channel, note, value = 0)
      super(id, socket, channel, note)
      @value = value
      @on_value = []
      socket.on_event(channel, :cc, note) do |event|
        @value = event.value
        Shmidi.TRACE("KNO\t#{@id}\t=#{@value}")
        @on_value.each { |b| b.call(self) }
      end
    end
  end

  def on_value(&block)
    @on_value << block
  end
end
