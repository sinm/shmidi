
module Shmidi
  # DEV = Xone2, APP = Traktor2
  class XoneK1 < Processor
    def initialize(indeces, dev_channel = 15)
      super(indeces)
      @dev_channel = dev_channel

      @move_enc = Encoder.new(:move_enc, @dev, @dev_channel, 21)
      @move_enc.on_value do |enc|
        enc.direction == :UP ? app_push(3, 1, 1) : app_push(3, 1, 127)
      end
      @size_swi =  Switch.new(:size_swi, @dev, @dev_channel, 'D1')

      # state reset
      @size = :xfine
      app_push(3, 2, 0)
      @size_swi.led.turn_off

      @size_swi.on_switch_state do |swi|
        @size, value = if swi.switch_state
          case(@size)
          when :xfine then [:beat, 63]
          when :fine then [:square, 84]
          else
            raise('undefined')
          end
        else
          case(@size)
          when :beat then [:xfine, 0]
          when :square then [:fine, 10]
          else
            raise('undefined')
          end
        end
        Shmidi.TRACE("SIZE\t#{@size}\t(#{value})")
        app_push(3, 2, value)
      end
      @move_but =  Button.new(:move_but, @dev, @dev_channel, 'D0')
      @move_but.on_press do |but|
        @size, value = case(@size)
          when :xfine then [:fine, 10]
          when :beat then [:square, 84]
          else
            raise('undefined')
          end
        Shmidi.TRACE("SIZE\t#{@size}\t(#{value})")
        app_push(3, 2, value)
      end
      @move_but.on_release do |but|
        @size, value = case(@size)
          when :fine then [:xfine, 0]
          when :square then [:beat, 63]
          else
            raise 'undefined'
          end
        Shmidi.TRACE("SIZE\t#{@size}\t(#{value})")
        app_push(3, 2, value)
      end
    end

    def app_push(channel, cc, value)
      @app.push(Event.new_cc(channel, cc, value))
    end

  end
end
