# encoding: utf-8

class Cookie

  # Models a registry of {Cookie} instances
  class Registry

    include Lupo.collection(:entries)
    include Adamantium::Flat

    # Message for {UnknownCookieError}
    UNKNOWN_COOKIE_MSG = 'No cookie named %s is registered'.freeze

    # Raised when trying to {#fetch} an unknown {Cookie}
    UnknownCookieError = Class.new(Cookie::Error)

    def self.coerce(header)
      new(cookie_hash(header))
    end

    def self.cookie_hash(header)
      header.split(COOKIE_SEPARATOR).each_with_object({}) { |string, hash|
        cookie = Cookie.coerce(string)
        hash[cookie.name] = cookie
      }
    end

    private_class_method :cookie_hash

    def self.new(entries = EMPTY_HASH)
      super
    end

    def fetch(name)
      get(name) or raise UnknownCookieError, UNKNOWN_COOKIE_MSG % name.inspect
    end

    def get(name)
      @entries[name]
    end

  end # class Registry
end # class Cookie
