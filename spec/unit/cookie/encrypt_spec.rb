# encoding: utf-8

require 'spec_helper'

describe Cookie, '#encrypt' do
  subject { object.encrypt(box) }

  let(:object) { described_class.new(name, value) }
  let(:name)   { double('name') }
  let(:value)  { double('value') }
  let(:box)    { double('box') }
  let(:cipher) { double('cipher') }

  before do
    expect(box).to receive(:encrypt).with(value).and_return(cipher)
  end

  it { should eql(described_class.new(name, cipher)) }
end
