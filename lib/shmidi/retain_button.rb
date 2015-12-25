# coding: utf-8
module Shmidi
  class RetainButton < LedButton
    def initialize(id, socket, channel, note)
      super
      @retained = false
      @retain_queue = Queue.new
      @retain_thread = Thread.new do
        loop do
          begin #TODO: everywhere else: insert exception handling inside loop
            next unless (counter = @retain_queue.pop) == @button.counter
            # sleep(2)
            # fun:
            # loop do
            #   def RandomLoadedClass.random_method
            #     nil
            #   end
            # end
            c = 0
            cancel = false
            loop do
              sleep(0.001)
              unless @button.counter == counter
                cancel = true
                break
              end
              break if (c += 1) > 1567
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
        #@led.turn_off
      end
    end
  end
end
