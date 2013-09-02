# encoding: utf-8

require 'spec_helper'

describe Cookie::Definition::Attribute::Set::Empty, '#to_s' do
  subject { object.to_s }

  let(:object) { described_class.new }

  it { should be(Cookie::EMPTY_STRING) }
end
