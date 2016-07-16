# coding: utf-8
module Shmidi
  class Encoder < Knob
    CTYPE = :ENC

    def increasing?
      @value == 1
    end
  end
end
