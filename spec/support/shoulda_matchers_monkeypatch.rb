module Shoulda
  module Matchers
    module ActiveModel
      class ValidateNumericalityOfMatcher
        def add_disallow_value_matcher
          disallow_value_matcher = DisallowValueMatcher.new(NON_NUMERIC_VALUE).
            for(@attribute).
            with_message(:not_a_number)
          disallow_value_matcher
            .instance_variable_get(:@allow_matcher)
            .ignoring_interference_by_writer

          add_submatcher(disallow_value_matcher)
        end
      end
    end
  end
end

module Shoulda
  module Matchers
    module ActiveRecord
      class ValidateUniquenessOfMatcher < ActiveModel::ValidationMatcher
        def dummy_scalar_value_for(column)
          # For polymorphic association columns, the '_type' field
          # must be set to a real model or it will raise a NameError
          if column.name.end_with?('_type')
            return 'User'
          end

          case column.type
            when :integer
              0
            when :date
              Date.today
            when :datetime
              DateTime.now
            when :uuid
              SecureRandom.uuid
            when :boolean
              true
            else
              'dummy value'
          end
        end
      end
    end
  end
end
