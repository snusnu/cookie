# encoding: utf-8

require 'spec_helper'

describe Cookie::Header::Attribute::Set, '#each' do
  let(:attributes) { described_class.new(entries) }
  let(:entries)    { Hash[name => attribute] }
  let(:attribute)  { double('attribute', :to_s => name) }
  let(:name)       { double('name') }

  it 'returns self when a block is given' do
    expect(attributes.each { |_| }).to be(attributes)
  end

  it 'returns an enumerator when no block is given' do
    expect(attributes.each).to be_instance_of(Enumerator)
  end

  it 'yields all attributes' do
    expect { |block| attributes.each(&block) }.to yield_successive_args(attribute)
  end
end
