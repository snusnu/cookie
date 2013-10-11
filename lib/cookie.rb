# encoding: utf-8

require 'time'
require 'base64'

require 'concord'
require 'adamantium'
require 'abstract_type'

# Models an HTTP Cookie
class Cookie

  # An empty frozen array
  EMPTY_ARRAY = [].freeze

  # An empty frozen hash
  EMPTY_HASH = {}.freeze

  # An empty frozen string
  EMPTY_STRING = ''.freeze

  # Separates the cookie name from its value
  NAME_VALUE_SEPARATOR = '='.freeze

  # Separates cookies
  COOKIE_SEPARATOR = '; '.freeze

  # Separates ruby class names in a FQN
  DOUBLE_COLON = '::'.freeze

  # Helper for cookie deletion
  class Empty < self
    def initialize(name)
      super(name, nil)
    end
  end

  # Namespace for cookie encoders
  module Encoder
    Base64 = ->(string) { ::Base64.urlsafe_encode64(string) }
  end

  # Namespace for cookie decoders
  module Decoder
    Base64 = ->(string) { ::Base64.urlsafe_decode64(string) }
  end

  # Cookie error base class
  Error = Class.new(StandardError)

  include Concord::Public.new(:name, :value)
  include Adamantium::Flat

  def self.coerce(string)
    new(*string.split(NAME_VALUE_SEPARATOR, 2))
  end

  def encode(encoder = Encoder::Base64)
    new(encoder.call(value))
  end

  def decode(decoder = Decoder::Base64)
    new(decoder.call(value))
  end

  def encrypt(box)
    new(box.encrypt(value))
  end

  def decrypt(box)
    new(box.decrypt(value))
  end

  def to_s
    "#{name}=#{value}"
  end
  memoize :to_s

  private

  def new(new_value)
    self.class.new(name, new_value)
  end

end # class Cookie

require 'cookie/header'
require 'cookie/header/attribute'
require 'cookie/registry'
