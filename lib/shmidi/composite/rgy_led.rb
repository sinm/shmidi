# coding: utf-8
module Shmidi
  class RGYLed
    include Base
    CTYPE = :RGY
    attr_reader :leds

    def initialize(red, green, yellow)
      @leds = {'red' => red, 'green' => green, 'yellow' => yellow}
    end

    def reset
      @leds.values.each {|led| led.reset}
    end

    def on?
      @leds.each {|color, led| return color if led.turned_on?}
      false
    end

    def turn_on(color = 'yellow', clock = nil)
      @leds.each do |c, led|
        next if c == color
        led.turn_off
      end
      @leds[color].turn_on(clock)
    end

    def turn_off(clock = nil)
      @leds.values.each {|led| led.turn_off(clock)}
    end

  end
end
