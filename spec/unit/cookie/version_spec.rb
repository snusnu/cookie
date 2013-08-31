# encoding: utf-8

describe Cookie::VERSION do
  it 'defines a VERSION constant' do
    expect { Cookie::VERSION }.to_not raise_error
  end
end
