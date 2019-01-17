# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do |example|
    Backport.notify!(*example.metadata[:backport]) if example.metadata[:backport]
  end
end
