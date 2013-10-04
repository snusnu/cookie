# encoding: utf-8

class Cookie

  # Models a transient, new cookie on the server that can be serialized
  # into an HTTP 'Set-Cookie' header.
  class Serializable

    # Models a cookie that is supposed to be deleted when serialized
    # into an HTTP 'Set-Cookie' header
    class Delete < self

      def initialize(name, attributes)
        super(Empty.new(name), attributes.merge(Attribute::Expired))
      end

    end # class Delete

    include Equalizer.new(:cookie, :attributes)
    include Adamantium::Flat

    attr_reader :cookie
    protected   :cookie

    attr_reader :attributes
    protected   :attributes

    def self.build(name, value, attributes)
      new(Cookie.new(name, value), attributes)
    end

    def initialize(cookie, attributes = Attribute::Set::EMPTY)
      @cookie, @attributes = cookie, attributes
    end

    def with_domain(domain)
      with_attribute(Attribute::Domain.new(domain))
    end

    def with_path(path)
      with_attribute(Attribute::Path.new(path))
    end

    def with_max_age(seconds)
      with_attribute(Attribute::MaxAge.new(seconds))
    end

    def with_expires(time)
      with_attribute(Attribute::Expires.new(time))
    end

    def secure
      with_attribute(Attribute::Secure.instance)
    end

    def http_only
      with_attribute(Attribute::HttpOnly.instance)
    end

    def delete
      Delete.new(cookie.name, attributes)
    end

    def to_s
      "#{cookie}#{attributes}"
    end
    memoize :to_s

    private

    def with_attribute(attribute)
      self.class.new(cookie, attributes.merge(attribute))
    end

  end # class Definition
end # class Cookie
