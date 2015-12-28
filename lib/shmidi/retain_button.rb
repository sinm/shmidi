# coding: utf-8
module Shmidi
  class RetainButton < LedButton
    @@clocks = {}
    def retain?
      !!@retained
    end
    def initialize(id, socket, channel, note, led_note=nil, delay=2, mode=nil)#mode=:blink_on_release)
      super(id, socket, channel, note, led_note)
      @@clocks[@socket] ||= OnOffClock.new(@socket)
      @mode = Array(mode)
      @retained = false
      @retain_queue = Queue.new
      @release_queue = Queue.new
      @retain_thread = Thread.new do
        loop do
          begin #TODO: everywhere else: insert exception handling inside loop
            next unless (counter = @retain_queue.pop) == @button.counter
            begin
              cancel = false
              Timeout.timeout(delay) do
                loop do
                  c = @release_queue.pop
                  next if c < counter
                  cancel = true
                  break
                end
              end
            rescue Timeout::Error
            end
            next if cancel
            if @mode.include?(:blink_on_release)
              while @button.counter <= counter + 1
                Shmidi.TRACE("BTN\t#{@id}\tRETAIN\t1") unless @retained
                @retained = true
                @led.turn_on(@@clocks[@socket])
                break unless @button.counter <= counter + 1
                @led.turn_off(@@clocks[@socket])
              end
              @led.turn_off if @retained
              @retained = false
              Shmidi.TRACE("BTN\t#{@id}\tRETAIN\t0")
            else # TODO: DRY
              while @button.counter == counter
                Shmidi.TRACE("BTN\t#{@id}\tRETAIN\t1") unless @retained
                @retained = true
                @led.turn_on(@@clocks[@socket])
                break unless @button.counter == counter
                @led.turn_off(@@clocks[@socket])
              end
              if @button.counter == counter + 1 && @retained # first release
                @led.turn_on # stay the led light
              else
                Shmidi.TRACE("BTN\t#{@id}\tRETAIN\t0")
                @retained = false
              end
            end
          rescue
            #TODO: dry exception output
            $stderr.puts($!)
            $stderr.puts($!.backtrace)
          end
        end
      end
      @button.on_press do |button|
        @retain_queue.push(button.counter)
      end
      @button.on_release do |button|
        @release_queue.push(button.counter)
      end
    end
  end
end
