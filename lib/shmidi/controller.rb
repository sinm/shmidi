# coding: utf-8
module Shmidi
  class Controller
    include Base
    attr_accessor :internals
    attr_reader :name
    def initialize(name)
      @name = name
      @internals = [[], {}]
    end

    def reset
      controls.values.each {|control| control.reset}
    end

    def sockets
      @internals.first
    end

    def controls
      @internals.last
    end
  end
end
