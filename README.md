# Backport

[![Build Status](https://travis-ci.org/nebulab/backport.svg?branch=master)](https://travis-ci.org/nebulab/backport)
[![Coverage Status](https://coveralls.io/repos/github/nebulab/backport/badge.svg?branch=master)](https://coveralls.io/github/nebulab/backport?branch=master)
[![Maintainability](https://api.codeclimate.com/v1/badges/c5705b7ed58864609452/maintainability)](https://codeclimate.com/github/nebulab/backport/maintainability)

Backport helps you manage backported code with ease.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'backport'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install backport

## Usage

Backport is used by registering checks and creating notices (which are only displayed if a certain 
check returns true). A check can be either _static_ (when its result is defined when the check
is defined) or _dynamic_ (when its result is computed every time a notice is defined). 

The following examples illustrates both types of checks:

```ruby
# This is a dynamic check: it accepts an argument and determines
# whether the Rails' version is greater than or equal to the argument. 
Backport.register_check(:rails_version_gte) do |version|
  Rails.gem_version > Gem::Version.new(version)
end

# You can also define dynamic checks by passing a proc as the
# second argument to register_check.
Backport.register_check(
  :rails_version_gte, 
  -> (version) { Rails.gem_version > Gem::Version.new(version) }
)

# This is a static check: its value is defined when the check is defined.
Backport.register_check(:rails5, Rails.gem_version >= Gem::Version.new('5.0.0')) 
```

And this is how you use both types of checks:

```ruby
def my_method
  Backport.notify('This method is not needed in Rails 5', :rails5)

  # ...
end

def my_other_method
  Backport.notify('This method is not needed since Rails 5.1', :rails_version_gte, '5.1.0')

  # ...
end
```

That's it!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run 
the tests. You can also run `bin/console` for an interactive prompt that will allow you to 
experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new 
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which 
will create a git tag for the version, push git commits and tags, and push the `.gem` file to 
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nebulab/backport. This 
project is intended to be a safe, welcoming space for collaboration, and contributors are expected 
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Backport project’s codebases, issue trackers, chat rooms and mailing 
lists is expected to follow the [code of conduct](https://github.com/nebulab/backport/blob/master/CODE_OF_CONDUCT.md).
