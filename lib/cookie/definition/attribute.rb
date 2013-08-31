# encoding: utf-8

class Cookie
  class Definition

    # Baseclass for cookie attributes
    class Attribute

      include Concord::Public.new(:name)
      include Adamantium::Flat

      def to_s
        name
      end

      # Models a set of attributes used within a {Definition}
      class Set

        include Equalizer.new(:attributes)
        include Enumerable
        include Adamantium::Flat

        attr_reader :attributes
        protected   :attributes

        def initialize(attributes = EMPTY_HASH)
          @attributes = attributes
        end

        def each(&block)
          return to_enum unless block
          attributes.each_value(&block)
          self
        end

        def merge(attribute)
          self.class.new(attributes.merge(attribute.name => attribute))
        end

        def to_s
          map(&:to_s).join(COOKIE_SEPARATOR)
        end
        memoize :to_s

      end # class Set

      # Abstract baseclass for attributes that consist of a name-value
      # pair
      #
      # @abstract
      class Binary < self

        include AbstractType
        include Equalizer.new(:name, :value)

        attr_reader :value
        protected   :value

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
        NAME = 'Domain'.freeze
      end

      # The Path attribute
      class Path < Binary
        NAME = 'Path'.freeze
      end

      # The Max-Age attribute
      class MaxAge < Binary
        NAME = 'MaxAge'.freeze

        private

        def serialized_value
          super.to_i
        end
      end

      # The Expires attribute
      class Expires < Binary
        NAME = 'Expires'.freeze

        private

        def serialized_value
          super.clone.gmtime.rfc2822
        end
      end

      # The Secure attribute
      Secure = new('Secure'.freeze)

      # The HttpOnly attribute
      HttpOnly = new('HttpOnly'.freeze)

      # Already expired {Expires} attribute useful for cookie deletion
      Expired = Expires.new(Time.at(0))

    end # class Attribute
  end # class Definition
end # class Cookie
