# frozen_string_literal: true

require 'active_support/deprecation'

require 'backport/version'
require 'backport/errors'

# Manage your backported code with ease.
module Backport
  class << self
    # Registers a check that can be used to trigger backport notices.
    #
    # Checks can be either static (with a result defined at the same time of the check's
    # definition) or dynamic (with a proc that is run each time the check is called to get
    # the result at that point in time).
    #
    # @param name [Symbol] name of the check
    # @param result [Boolean|Proc] a value (for static checks) or proc (for dynamic checks)
    # @param block [Proc] a block that returns the check's value
    #
    # @raise [ArgumentError] if both (or neither) a static and dynamic value are passed
    def register_check(name, result = nil, &block)
      if (result.nil? && !block_given?) || (!result.nil? && block_given?)
        raise ArgumentError, 'You must provide either a value or a block.'
      end

      checks[name.to_sym] = block_given? ? block : result
    end

    # Notifies a backport notice when a check results true.
    #
    # This will use whatever behavior was set for ActiveSupport::Deprecation (the
    # default behavior prints the deprecation message to stderr).
    #
    # Any additional arguments will be passed to the check if it's a block or proc.
    #
    # @param message [String] backport message
    # @param check [Symbol] name of the check
    #
    # @raise [ArgumentError] if an invalid check is specified
    #
    # @see https://api.rubyonrails.org/classes/ActiveSupport/Deprecation/Behavior.html
    def notify(message, check, *args)
      return unless run_check(check, *args)

      caller_method = if defined?(Rails) && Rails.gem_version < Gem::Version.new('5.0')
                        caller(2)
                      else
                        caller_locations(2)
                      end

      ActiveSupport::Deprecation.warn(message, caller_method)
    end

    # Raises an +ActiveSupport::DeprecationException+ if a check results true.
    #
    # This will force the +:raise+ behavior and then resume the previous behavior
    # after the execution of the method.
    #
    # Any additional arguments will be passed to the check if it's a block or proc.
    #
    # @param message [String] backport message
    # @param check [Symbol] name of the check
    #
    # @raise [ActiveSupport::DeprecationException] if the check results true
    #
    # @see https://api.rubyonrails.org/classes/ActiveSupport/Deprecation/Behavior.html
    def notify!(message, check, *args)
      previous_behavior = ActiveSupport::Deprecation.behavior
      ActiveSupport::Deprecation.behavior = :raise
      notify(message, check, *args)
    ensure
      ActiveSupport::Deprecation.behavior = previous_behavior
    end

    private

    def checks
      @checks ||= {}
    end

    def run_check(name, *args)
      raise UndefinedCheckError, "Check #{name} is undefined" if checks[name].nil?

      result = if checks[name].is_a?(Proc)
                 checks[name].call(*args)
               else
                 checks[name]
               end

      !!result
    end
  end
end
