# coding: utf-8
module Shmidi
  class LedButton < Control
    def initialize(id, socket, channel, note, led_note = nil)
      super
      @button = Button.new(id, socket, channel, note)
      @led = Led.new(id, socket, channel, led_note || note)
      @button.on_press do |button|
        @led.turn_on
      end
      @button.on_release do |button|
        @led.turn_off
      end
    end
  end
end
