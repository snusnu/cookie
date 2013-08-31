# encoding: utf-8

class Cookie

  # Models a transient, new cookie on the server that can be serialized
  # into an HTTP 'Set-Cookie' header.
  class Definition

    # Models a cookie that is supposed to be deleted when serialized
    # into an HTTP 'Set-Cookie' header
    class Delete < self

      def initialize(name, attributes)
        super(Cookie::Empty.new(name), attributes.merge(Attribute::Expired))
      end

    end # class Delete

    include Equalizer.new(:cookie, :attributes)
    include Adamantium::Flat

    attr_reader :cookie
    protected   :cookie

    attr_reader :attributes
    protected   :attributes

    def initialize(cookie, attributes = Attribute::Set.new)
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
      with_attribute(Attribute::Secure)
    end

    def http_only
      with_attribute(Attribute::HttpOnly)
    end

    def delete
      Delete.new(cookie.name, attributes)
    end

    def to_s
      "#{cookie}#{COOKIE_SEPARATOR}#{attributes}".strip
    end
    memoize :to_s

    private

    def with_attribute(attribute)
      new(cookie, attributes.merge(attribute))
    end

    def new(cookie, attributes)
      self.class.new(cookie, attributes)
    end

  end # class Definition
end # class Cookie
