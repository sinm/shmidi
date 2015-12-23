# coding: utf-8
module Shmidi
  class Processor

    def initialize(indeces)

      @app_in = UniMIDI::Input.all.find{|d| d.id == indeces[0]}
      @app_out = UniMIDI::Output.all.find{|d| d.id == indeces[1]}
      @dev_in = UniMIDI::Input.all.find{|d| d.id == indeces[2]}
      @dev_out = UniMIDI::Output.all.find{|d| d.id == indeces[3]}
      @listeners = {}
      @queue = Queue.new
    end

    def self.print_device_list
      $stdout.puts('Inputs:')
      UniMIDI::Input.list
      $stdout.puts('Outputs:')
      UniMIDI::Output.list
    end

    def start
      {:APP => @app_in, :DEV => @dev_in}.each do |name, socket|
        @listeners[name] ||= Thread.new do
          begin
            loop do
              socket.gets.each do |e|
                e[:source] = name
                @queue.push(Event.new(e))
              end
            end
          rescue
            $stderr.puts($!)
            $stderr.puts($!.backtrace)
          end
        end
      end
      @processing ||= Thread.new do
        begin
          loop do
            event = @queue.pop
            puts("< #{event.source}\t#{event}")
          end
        rescue
          $stderr.puts($!)
          $stderr.puts($!.backtrace)
        end
      end
    end

    def join
      @processing.join if @processing
    end

    # TODO: Завести свой Device, где
    # - будет имя,
    # - В конструкторе @dev_out, @dev_in (@app_out, @app_in)
    # - будет состояние

    def notes_off(channel)
      0.upto(127) do |note_int|
        event = Event.new(:channel => channel,
                          :message => :off,
                          :note_int=> note_int,
                          :value=>0)
        @dev_out.puts(event.data)
        puts("> #{:DEV}\t#{event}")
      end
    end

    def random_on_off(channel, timeout=1)
      r = Random.new
      Timeout.timeout(timeout) do
        loop do
          event = Event.new(:channel => channel,
                            :message => (r.rand(2) > 0 ? :on : :off),
                            :note_int=> r.rand(128),
                            :value=>r.rand(128))
          @dev_out.puts(event.data)
        end
      end
    rescue TimeoutError
    rescue
      $stderr.puts($!)
      $stderr.puts($!.backtrace)
    ensure
      notes_off(channel)
    end

    def blink(channel, note, timeout)
      Timeout.timeout(timeout) do
        loop do
          [[:on, 127], [:off,0]].each do |e|
            event = Event.new(:channel => channel,
                              :message => e[0],
                              :note_int => note, #TODO: принимать int или str
                              :value=>e[1])
            @dev_out.puts(event.data)
            puts("> #{:DEV}\t#{event}")
            sleep(0.04)
          end
        end
      end
    rescue
      puts($!)
    ensure
      event = Event.new(:channel => channel,
                        :message => :off,
                        :note_int=> note,
                        :value=>0)
      @dev_out.puts(event.data)
    end

  private


  end
end
