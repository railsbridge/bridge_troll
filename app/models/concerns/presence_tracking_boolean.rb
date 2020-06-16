# frozen_string_literal: true

module PresenceTrackingBoolean
  extend ActiveSupport::Concern

  # Add a setter and getter for a non-database-backed field representing
  # whether some other field is present. Assigning something falsy
  # to the setter will unset the tracked value.
  #
  #
  # ```
  # Rsvp.add_presence_tracking_boolean(:needs_childcare, :childcare_info)
  #
  # rsvp = Rsvp.first
  # rsvp.childcare_info   # 'Some String'
  # rsvp.needs_childcare? # true
  #
  # # Rails forms will assign '0' or '1' (instead of `true` or `false`)
  # # to a non-database-backed checkbox field, usually
  #
  # rsvp.assign_attributes(needs_childcare: '0')
  # rsvp.needs_childcare? # false
  # rsvp.childcare_info   # nil
  # ```

  included do
    def self.add_presence_tracking_boolean(boolean_attribute, tracked_attribute)
      ivar_symbol = :"@#{boolean_attribute}"

      define_method :"#{boolean_attribute}?" do
        unless instance_variable_defined?(ivar_symbol)
          instance_variable_set(ivar_symbol, send(tracked_attribute).present?)
        end
        instance_variable_get(ivar_symbol)
      end

      alias_method boolean_attribute, :"#{boolean_attribute}?"

      define_method :"#{boolean_attribute}=" do |value|
        value = value == '1' if value.is_a? String

        assign_attributes(tracked_attribute => nil) unless value

        instance_variable_set(ivar_symbol, value)
      end

      define_method :"#{tracked_attribute}=" do |value|
        return if instance_variable_defined?(ivar_symbol) && !instance_variable_get(ivar_symbol)

        super(value)
      end
    end
  end
end
