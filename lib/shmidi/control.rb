# coding: utf-8
module Shmidi
  class Control
    include Base
    attr_accessor :channel, :note

    def socket
      Socket[@socket]
    end

    def initialize(socket, channel, note)
      @socket = socket
      @channel = channel
      @note = note
    end

    def id
      "#{@channel}:#{@note}"
    end
  end
end
