# coding: utf-8
module Shmidi
  class Event
    # TODO: MID_NOTE

    attr_reader :source
    attr_reader :data, :timestamp
    attr_reader :channel, :message_int, :note_int, :value
    attr_reader :message, :note, :octave

    MESSAGES ||= begin
      h = { 8  => :off,
            9   => :on,
            11  => :cc,
            14  => :pitch}
      h.keys.each {|k| h[h[k]] = k}
      h
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
        if [:on, :off].include?(@message)
          @octave   = (@note_int / 12) - 1
          @note     = 'C C#D D#E F F#G G#A A#B '[((@note_int % 12) * 2), 2].strip
        end
        @value      = @data[2]
      else # no numeric data array
        @value = h[:value] || 0 # TODO: || default value for message
        @channel = h[:channel] || 1
        if @note_int = h[:note_int]
          #TODO: only if :on,:off else note_int
          #TODO: dry
          @octave   = (@note_int / 12) - 1
          @note     = 'C C#D D#E F F#G G#A A#B '[((@note_int % 12) * 2), 2].strip
        else
          if h[:note][-1] =~ /\d/
            @octave = h[:note][-1].to_i
            @note = h[:note][0..-2]
          else
            @octave = h[:octave]
            @note = h[:note]
          end
          @note_int = (@octave * 12 + 'C C#D D#E F F#G G#A A#B '.index(@note))
        end
        @data = [0,0,0]
        @data[1] = @note_int
        @data[2] = @value
        @message = h[:message]
        @message_int = h[:message_int] || MESSAGES[@message] || @message
        @message = MESSAGES[@message_int]
        @data[0] = (@message_int << 4) + (@channel - 1)
      end
    end

    def transform(&block)
      instance_exec(&block)
    end

    def to_s
      "CH:#{@channel}\t#{@message}\t#{@note}#{@octave}\t=#{@value}"
    end

    def to_hash
      hash = {}
      instance_variables.each do |var|
        hash[var[1..-1].to_sym] = instance_variable_get(var)
      end
      hash
    end
  end
end
