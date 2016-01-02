# coding: utf-8
module Shmidi
  class Encoder < Knob
    CTYPE = :ENC

    def direction
      @value == 1 ? :UP : :DOWN
    end

  end
end
