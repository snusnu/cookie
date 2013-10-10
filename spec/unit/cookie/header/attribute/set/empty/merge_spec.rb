# encoding: utf-8

require 'spec_helper'

describe Cookie::Header::Attribute::Set::Empty, '#merge' do
  subject { object.merge(attribute) }

  let(:object)    { described_class.new }
  let(:attribute) { double('attribute', :name => name) }
  let(:name)      { double('name') }

  it { should eql(Cookie::Header::Attribute::Set.new(name => attribute)) }
end
