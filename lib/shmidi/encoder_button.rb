# coding: utf-8
module Shmidi
  class EncoderButton < Control
    CTYPE = :ENCBUT
    attr_reader :encoder, :button

    def initialize(id, socket, channel, note, button_note, value = 0)
      super(id, socket, channel, note)
      @encoder = Encoder.new(id, socket, channel, note, value)
      @button = Button.new(id, socket, channel, button_note)
    end
  end
end
