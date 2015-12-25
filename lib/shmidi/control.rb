# coding: utf-8
module Shmidi
  class Control
    attr_accessor :id # NOTE: may be array kind of [row, column]
    attr_accessor :name # optional name
    attr_accessor :socket, :channel, :note

    def initialize(id, socket, channel, note)
      @id = id
      @socket = socket
      @channel = channel
      @note = note
    end
  end
end
