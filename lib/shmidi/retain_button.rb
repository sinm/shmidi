# coding: utf-8
module Shmidi
  class RetainButton < LedButton
    CTYPE = :RETBUT
    @@clocks = {}
    def retain?
      !!@retained
    end
    def initialize(id, socket, channel, note, led_note = nil, delay = 2)
      super(id, socket, channel, note, led_note)
      @@clocks[@socket] ||= OnOffClock.new(@socket)
      @retained = false
      @retain_queue = Queue.new
      @release_queue = Queue.new
      @retain_thread = Thread.new do
        loop do
          begin
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
            while @button.counter <= counter + 1
              Shmidi.TRACE("#{CTYPE}\t#{@id}\tRETAIN\t1") unless @retained
              @retained = true
              @led.turn_on(@@clocks[@socket])
              break unless @button.counter <= counter + 1
              @led.turn_off(@@clocks[@socket])
            end
            @led.turn_off if @retained
            @retained = false
            Shmidi.TRACE("#{CTYPE}\t#{@id}\tRETAIN\t0")
          rescue
            Shmidi.ON_EXCEPTION
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
