# coding: utf-8
module Shmidi
  class Processor
    ALL_NOTES = (0..127).to_a
    def notes_rand(channel, timeout=1, delay=0.05)
      r = Random.new
      Timeout.timeout(timeout) do
        loop do
          @dev.push(ALL_NOTES.map do |note|
            r.rand(2) == 0  ? Event.new_off(channel, note) :
                              Event.new_on(channel, note)
          end)
          sleep(delay)
        end
      end
    rescue Timeout::Error
    rescue
      $stderr.puts($!)
      $stderr.puts($!.backtrace)
    ensure
      notes_off(channel)
    end


    def notes_off(channel, value = 0)
      @dev.push(ALL_NOTES.map do |note|
        Event.new_off(channel, note, value)
      end)
    end

    def notes_blink(channel, timeout = 1, on_t = 0.5, off_t = 0.5)
      Timeout.timeout(timeout) do
        loop do
          @dev.push(ALL_NOTES.map do |note|
            Event.new_on(channel, note)
          end)
          sleep(on_t)
          @dev.push(ALL_NOTES.map do |note|
            Event.new_off(channel, note)
          end)
          sleep(off_t)
        end
      end
    rescue Timeout::Error
    rescue
      puts($!)
    ensure
      notes_off(channel)
    end
  end
end
