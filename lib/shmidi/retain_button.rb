# coding: utf-8
module Shmidi
  class RetainButton < LedButton
    def initialize(id, socket, channel, note, led_note =nil, delay = 2)
      super(id, socket, channel, note, led_note)
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
            while @button.counter == counter
              @led.turn_on
              break unless @button.counter == counter
              @retained = true
              sleep(0.133);
              break unless @button.counter == counter
              @led.turn_off
              sleep(0.133);
            end
            if @button.counter == counter + 1 && @retained # first release
              @led.turn_on # stay the led light
            else
              @retained = false
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
