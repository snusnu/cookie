# encoding: utf-8

require 'spec_helper'

describe Cookie, '#decrypt' do
  subject { object.decrypt(box) }

  let(:object) { described_class.new(name, cipher) }
  let(:name)   { double('name') }
  let(:cipher) { double('cipher') }
  let(:box)    { double('box') }
  let(:value)  { double('value') }

  before do
    expect(box).to receive(:decrypt).with(cipher).and_return(value)
  end

  it { should eql(described_class.new(name, value)) }
end
