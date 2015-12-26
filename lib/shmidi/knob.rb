# coding: utf-8
module Shmidi
  # NOTE: not faster than
  # ~5 changes in one direction from min to max or otherwise
  class Knob < Control
    attr_reader :value

    def initialize(id, socket, channel, note, value = 0)
      super(id, socket, channel, note)
      @prev_value = value
      @value = value
      @type = :KNO
      @on_value = []
      socket.on_event(channel, :cc, note) do |event|
        @prev_value = @value
        if [1,127].include?(@value) && [1,127].include?(event.value)
          @type = :ENC
        end
        @value = event.value
        Shmidi.TRACE("#{@type}\t#{@id}\t#{direction}\t#{@value}")
        @on_value.each { |b| b.call(self) }
      end
    end

    def direction
      if @type == :KNO
        @prev_value > @value ? :DOWN : :UP
      else # :ENC
        @value == 1 ? :DOWN : :UP
      end
    end

    def on_value(&block)
      @on_value << block
    end
  end
end
