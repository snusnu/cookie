# encoding: utf-8

require 'cookie'

# MUST happen after ice_nine
# got required by substation
require 'devtools/spec_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.mock_with :rspec do |c|
    c.syntax = :expect
  end
end
