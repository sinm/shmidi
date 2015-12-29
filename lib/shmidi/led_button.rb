# coding: utf-8
module Shmidi
  class LedButton < Control
    attr_reader :button, :led

    def initialize(id, socket, channel, note, led_note = nil)
      super(id, socket, channel, note)
      @button = Button.new(id, socket, channel, note)
      @led = Led.new(id, socket, channel, led_note || note)
      @button.on_press(&lambda { |button| on_button_press(button) })
      @button.on_release(&lambda { |button| on_button_release(button) })
    end

    protected

    def on_button_press(button)
      @led.turn_on
    end

    def on_button_release(button)
      @led.turn_off
    end
  end
end
