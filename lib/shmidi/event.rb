# coding: utf-8
module Shmidi
  class Event
    #TODO: eat symbols and strings as needed for shmidi piping
    attr_reader :source
    attr_reader :data, :timestamp
    attr_reader :channel, :message_int, :note_int, :value
    attr_reader :message, :note

    MESSAGES ||= begin
      h = { 8  => :off,
            9   => :on,
            11  => :cc,
            14  => :pitch}
      h.keys.each {|k| h[h[k]] = k}
      h
    end

    def octave
      return nil unless @note.kind_of?(String)
      (@note_int / 12) - 1
    end

    def initialize(h)
      @source     = h[:source]
      @timestamp  = (h[:timestamp] || 0).floor
      @data       = h[:data].clone if h[:data]
      if @data
        @channel    = (@data[0] & 0x0f) + 1
        @message_int= @data[0] >> 4
        @message    = @message_int
        @message    = MESSAGES[@message_int] || @message_int
        @note_int   = @data[1]
        @note       = @note_int
        parse_note_int if [:on, :off].include?(@message)
        @value      = @data[2]
      else # no numeric data array
        @message_int = h[:message_int] || MESSAGES[h[:message]] || h[:message]
        @message = MESSAGES[@message_int]
        @value = h[:value] || 0
        @channel = h[:channel] || 1
        @note = h[:note]
        @note_int = h[:note]
        if h[:note].kind_of?(Numeric) && [:on, :off].include?(@message)
          parse_note_int
        elsif h[:note].kind_of?(String)
          @note = h[:note]
          #@note += h[:note][1] if h[:note][1] == '#'
          h[:note] =~ /^(.#?)(-?\d+)$/
          @note_int = ($2.to_i + 1) * 12 + 'C C#D D#E F F#G G#A A#B '.index($1) / 2
        end
        @data = [0,0,0]
        @data[1] = @note_int
        @data[2] = @value
        @data[0] = (@message_int << 4) + (@channel - 1)
      end
    end

    def self.new_on(channel, note, value = 127)
      Event.new(
        :channel  => channel,
        :message  => :on,
        :note     => note,
        :value    => value)
    end

    def self.new_off(channel, note, value = 0)
      Event.new(
        :channel  => channel,
        :message  => :off,
        :note     => note,
        :value    => value)
    end

    def self.new_cc(channel, cc, value)
      Event.new(
        :channel  => channel,
        :message  => :cc,
        :note     => cc,
        :value    => value)
    end

    def to_s
      "CH:#{@channel}\t#{@message}\t#{@note}\t=#{@value}"
    end

    def to_hash
      hash = {}
      instance_variables.each do |var|
        hash[var[1..-1].to_sym] = instance_variable_get(var)
      end
      hash
    end

    private

    def parse_note_int
      @note     = 'C C#D D#E F F#G G#A A#B '[((@note_int % 12) * 2), 2].strip
      @note += "#{octave}"
    end
  end
end
