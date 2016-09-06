# coding: utf-8
module Shmidi
  class Switch < LedButton
    CTYPE = :SWI
    attr_reader :switch_state
    def initialize(id, socket, channel, note, led_note = nil)
      super(id, socket, channel, note, led_note)
      @switch_state = false
      @on_switch = []
    end

    def on_switch_state(&block)
      @on_switch << block
    end

    protected

    def on_button_press(button)
      (@switch_state = !@switch_state) ? @led.turn_on : @led.turn_off
      Shmidi.TRACE {"#{CTYPE}\t#{@id}\tSTATE\t#{@switch_state ? :ON : :OFF}"}
      @on_switch.each { |b| b.call(self) }
    end

    def on_button_release(button)
      nil
    end
  end
end
