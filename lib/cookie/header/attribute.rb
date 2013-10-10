# encoding: utf-8

class Cookie
  class Header

    # Baseclass for cookie attributes
    class Attribute

      include Concord::Public.new(:name)
      include Adamantium

      REGISTRY = {}

      def self.coerce(name, value)
        REGISTRY.fetch(name.to_sym).build(value)
      end

      def self.register_as(name)
        REGISTRY[name.to_sym] = self
      end

      def to_s
        name
      end

      # Models a set of attributes used within a {Serializable} cookie
      class Set

        include Concord.new(:attributes)
        include Enumerable
        include Adamantium

        def self.coerce(attributes)
          new(attributes.each_with_object({}) { |(name, value), hash|
            attribute = Attribute.coerce(name, value)
            hash[attribute.name] = attribute if attribute
          })
        end

        def each(&block)
          return to_enum unless block
          attributes.each_value(&block)
          self
        end

        def merge(attribute)
          Set.new(attributes.merge(attribute.name => attribute))
        end

        def to_s
          "#{COOKIE_SEPARATOR}#{map(&:to_s).join(COOKIE_SEPARATOR)}"
        end
        memoize :to_s

        # An empty {Set} to be serialized to {EMPTY_STRING}
        class Empty < self

          def initialize
            super(EMPTY_HASH)
          end

          def to_s
            EMPTY_STRING
          end

        end # class Empty

        EMPTY = Empty.new

      end # class Set

      # Abstract baseclass for attributes that have no value
      #
      # @abstract
      class Unary < self

        include AbstractType

        CACHE = {}

        def self.build(value)
          value ? instance : nil
        end

        def self.instance
          name = self::NAME
          CACHE.fetch(name) { CACHE[name] = new(name) }
        end

      end

      # Abstract baseclass for attributes that consist of a name-value
      # pair
      #
      # @abstract
      class Binary < self

        include AbstractType
        include Equalizer.new(:name, :value)

        attr_reader :value
        protected   :value

        def self.build(value)
          new(value)
        end

        def initialize(value)
          super(self.class::NAME)
          @value = value
        end

        def to_s
          "#{name}=#{serialized_value}"
        end
        memoize :to_s

        private

        def serialized_value
          value
        end

      end # class Binary

      # The Domain attribute
      class Domain < Binary
        register_as :domain
        NAME = 'Domain'.freeze
      end

      # The Path attribute
      class Path < Binary
        register_as :path
        NAME = 'Path'.freeze
      end

      # The Max-Age attribute
      class MaxAge < Binary
        register_as :max_age
        NAME = 'MaxAge'.freeze
      end

      # The Expires attribute
      class Expires < Binary
        register_as :expires
        NAME = 'Expires'.freeze

        private

        def serialized_value
          super.dup.gmtime.rfc2822
        end
      end

      # The Secure attribute
      class Secure < Unary
        register_as :secure
        NAME = 'Secure'.freeze
      end

      # The HttpOnly attribute
      class HttpOnly < Unary
        register_as :http_only
        NAME = 'HttpOnly'.freeze
      end

      # Already expired {Expires} attribute useful for cookie deletion
      Expired = Expires.new(Time.at(0))

    end # class Attribute
  end # class Header
end # class Cookie
