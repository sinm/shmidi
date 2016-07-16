module Shmidi
  module Base
    CTYPE = :ABS
    attr_accessor :_id
    attr_accessor :_rev
    attr_accessor :_deleted
    attr_accessor :_attachments
    attr_accessor :version

    def to_hash
      hash = {JSON_CREATE_ID => self.class.name}
      instance_variables.each do |var|
        hvar = var[1..-1]
        next if hvar =~ /^__/
        hash[hvar] = instance_variable_get(var)
      end
      hash
    end

    def init
      # ABSTRACT
    end

    def reset
      # ABSTRACT
    end

    def to_s
      dump
    end

    def dump
      Shmidi::DUMP(to_hash)
    end

    def inspect
      Shmidi::PRETTY(self)
    end

    def [](arg)
      send arg.to_sym
    end
    def []=(arg, value)
      send "#{arg}=".to_sym, value
    end

    def clone
      self.class.ensure(dump)
    end

    def etag
      "\"#{_rev}\""
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def ensure(obj)
        # ------
        m = if obj.kind_of?(self)
          obj
        elsif obj.kind_of?(Hash)
          self.json_create(obj)
        elsif obj.kind_of?(String)
          self.ensure(Shmidi::JSON_PARSE(obj))
        else
          nil
        end
        (block_given? && m) ? yield(m) : m
      end

      def json_create(hash = {})
        obj = allocate
        hash.each do |key, value|
          begin
            obj.instance_variable_set("@#{key}", value)
          rescue Exception
            Shmidi::ON_EXCEPTION
          end
        end
        obj.version ||= 0
        obj.init
        obj.reset
        return obj
      end
    end
  end
end
