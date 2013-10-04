# encoding: utf-8

require 'spec_helper'

module Spec
  class CryptoBox
    def encrypt(string)
      string
    end

    def decrypt(string)
      string
    end
  end

  module Encoder
    Noop = ->(string) { string }
  end

  module Decoder
    Noop = ->(string) { string }
  end
end

shared_context 'integration specs' do
  let(:cookie) { Cookie.new(name, value) }
  let(:name)   { 'SID' }
  let(:value)  { '{"id": 11}' } # triggers padding char '=' when base64 encoded
end

describe Cookie do

  include_context 'integration specs'

  let(:encoder) { Spec::Encoder::Noop }
  let(:decoder) { Spec::Decoder::Noop }
  let(:box)     { Spec::CryptoBox.new }

  it 'supports coercion from string to a Cookie instance' do
    c = cookie
    expect(Cookie.coerce(c.to_s)).to eql(cookie)

    c = cookie.encode
    expect(Cookie.coerce(c.to_s)).to eql(cookie.encode)

    c = c.decode
    expect(Cookie.coerce(c.to_s)).to eql(cookie)
  end

  it 'supports #name and #value' do
    expect(cookie.name).to be(name)
    expect(cookie.value).to be(value)
  end

  it 'supports #to_s' do
    expect(cookie.to_s).to eql("#{cookie.name}=#{cookie.value}")
  end

  context 'encoding and decoding' do
    it 'defaults to base64' do
      encoded = cookie.encode
      expect(encoded).to eql(Cookie.new(name, Base64.urlsafe_encode64(cookie.value)))

      decoded = encoded.decode
      expect(decoded).to eql(Cookie.new(name, Base64.urlsafe_decode64(encoded.value)))
    end

    it 'supports custom encoders and decoders' do
      encoded = cookie.encode(encoder)
      expect(encoded).to eql(Cookie.new(name, encoder.call(cookie.value)))

      decoded = encoded.decode(decoder)
      expect(decoded).to eql(Cookie.new(name, decoder.call(encoded.value)))
    end
  end

  context 'encryption and decryption' do
    it 'supports crypto boxes which provide #encrypt(msg) and #decrypt(msg)' do
      encrypted = cookie.encrypt(box)
      expect(encrypted).to eql(Cookie.new(name, box.encrypt(cookie.value)))

      decrypted = encrypted.decrypt(box)
      expect(decrypted).to eql(Cookie.new(name, box.decrypt(encrypted.value)))
    end
  end
end

describe Cookie::Definition do

  include_context 'integration specs'

  let(:definition) { Cookie::Definition.new(cookie) }

  it 'supports all cookie attributes' do
    d = definition
    expect(d.to_s).to eql('SID={"id": 11}')

    d = definition.with_domain('.foo.bar')
    expect(d.to_s).to eql('SID={"id": 11}; Domain=.foo.bar')

    d = d.with_path('/foo')
    expect(d.to_s).to eql('SID={"id": 11}; Domain=.foo.bar; Path=/foo')

    d = d.with_expires(Time.at(42))
    expect(d.to_s).to eql('SID={"id": 11}; Domain=.foo.bar; Path=/foo; Expires=Thu, 01 Jan 1970 00:00:42 -0000')

    d = d.with_max_age(42)
    expect(d.to_s).to eql('SID={"id": 11}; Domain=.foo.bar; Path=/foo; Expires=Thu, 01 Jan 1970 00:00:42 -0000; MaxAge=42')

    d = d.secure
    expect(d.to_s).to eql('SID={"id": 11}; Domain=.foo.bar; Path=/foo; Expires=Thu, 01 Jan 1970 00:00:42 -0000; MaxAge=42; Secure')

    d = d.http_only
    expect(d.to_s).to eql('SID={"id": 11}; Domain=.foo.bar; Path=/foo; Expires=Thu, 01 Jan 1970 00:00:42 -0000; MaxAge=42; Secure; HttpOnly')

    d = definition.secure
    expect(d.to_s).to eql('SID={"id": 11}; Secure')

    d = d.http_only
    expect(d.to_s).to eql('SID={"id": 11}; Secure; HttpOnly')

    d = definition.http_only
    expect(d.to_s).to eql('SID={"id": 11}; HttpOnly')

    d = d.secure
    expect(d.to_s).to eql('SID={"id": 11}; HttpOnly; Secure')
  end

  it 'overwrites previously defined attributes' do
    d = definition.with_max_age(0).with_max_age(42)
    expect(d.to_s).to eql('SID={"id": 11}; MaxAge=42')
  end

  it 'supports deleting cookies on the client' do
    d = definition.delete
    expect(d.to_s).to eql('SID=; Expires=Thu, 01 Jan 1970 00:00:00 -0000')

    d = definition.with_domain('.foo.bar').with_path('/foo')
    d = d.delete
    expect(d.to_s).to eql('SID=; Domain=.foo.bar; Path=/foo; Expires=Thu, 01 Jan 1970 00:00:00 -0000')
  end
end

describe Cookie::Registry do

  include_context 'integration specs'

  let(:registry) { Cookie::Registry.coerce(header) }
  let(:header)   { cookie.to_s }

  it 'contains no entries after #initialize' do
    expect(Cookie::Registry.new.count).to be(0)
  end

  it 'supports coercion from a Set-Cookie header' do
    expect(registry.get(name)).to eql(cookie)
  end

  it 'supports #get(name)' do
    expect(registry.get(name)).to eql(cookie)
    expect(registry.get(:foo)).to be(nil)
  end

  it 'supports #fetch(name)' do
    expect(registry.fetch(name)).to eql(cookie)
    expect { registry.fetch(:foo) }.to raise_error(Cookie::Registry::UnknownCookieError)
  end

  it 'is an Enumerable' do
    expect(registry).to be_kind_of(Enumerable)
  end

  context '#each' do
    it 'returns self when a block is given' do
      expect(registry.each { |_| }).to be(registry)
    end

    it 'returns an enumerator when no block is given' do
      expect(registry.each).to be_instance_of(Enumerator)
    end

    it 'yields all cookies' do
      expect { |block| registry.each(&block) }.to yield_successive_args([name, cookie])
    end
  end
end
