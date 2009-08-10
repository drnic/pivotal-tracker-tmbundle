module ActiveRecord
  module AttributeMethods
    # Track unsaved attribute changes.
    #
    # A newly instantiated object is unchanged:
    #   person = Person.find_by_name('Uncle Bob')
    #   person.changed?       # => false
    #
    # Change the name:
    #   person.name = 'Bob'
    #   person.changed?       # => true
    #   person.name_changed?  # => true
    #   person.name_was       # => 'Uncle Bob'
    #   person.name_change    # => ['Uncle Bob', 'Bob']
    #   person.name = 'Bill'
    #   person.name_change    # => ['Uncle Bob', 'Bill']
    #
    # Save the changes:
    #   person.save
    #   person.changed?       # => false
    #   person.name_changed?  # => false
    #
    # Assigning the same value leaves the attribute unchanged:
    #   person.name = 'Bill'
    #   person.name_changed?  # => false
    #   person.name_change    # => nil
    #
    # Which attributes have changed?
    #   person.name = 'Bob'
    #   person.changed        # => ['name']
    #   person.changes        # => { 'name' => ['Bill', 'Bob'] }
    #
    # Resetting an attribute returns it to its original state:
    #   person.reset_name!    # => 'Bill'
    #   person.changed?       # => false
    #   person.name_changed?  # => false
    #   person.name           # => 'Bill'
    #
    # Before modifying an attribute in-place:
    #   person.name_will_change!
    #   person.name << 'y'
    #   person.name_change    # => ['Bill', 'Billy']
    module Dirty
      extend ActiveSupport::Concern

      DIRTY_AFFIXES = [
        { :suffix => '_changed?' },
        { :suffix => '_change' },
        { :suffix => '_will_change!' },
        { :suffix => '_was' },
        { :prefix => 'reset_', :suffix => '!' }
      ]

      included do
        attribute_method_affix *DIRTY_AFFIXES

        alias_method_chain :save,            :dirty
        alias_method_chain :save!,           :dirty
        alias_method_chain :update,          :dirty
        alias_method_chain :reload,          :dirty

        superclass_delegating_accessor :partial_updates
        self.partial_updates = true
      end

      # Do any attributes have unsaved changes?
      #   person.changed? # => false
      #   person.name = 'bob'
      #   person.changed? # => true
      def changed?
        !changed_attributes.empty?
      end

      # List of attributes with unsaved changes.
      #   person.changed # => []
      #   person.name = 'bob'
      #   person.changed # => ['name']
      def changed
        changed_attributes.keys
      end

      # Map of changed attrs => [original value, new value].
      #   person.changes # => {}
      #   person.name = 'bob'
      #   person.changes # => { 'name' => ['bill', 'bob'] }
      def changes
        changed.inject({}) { |h, attr| h[attr] = attribute_change(attr); h }
      end

      # Attempts to +save+ the record and clears changed attributes if successful.
      def save_with_dirty(*args) #:nodoc:
        if status = save_without_dirty(*args)
          changed_attributes.clear
        end
        status
      end

      # Attempts to <tt>save!</tt> the record and clears changed attributes if successful.
      def save_with_dirty!(*args) #:nodoc:
        status = save_without_dirty!(*args)
        changed_attributes.clear
        status
      end

      # <tt>reload</tt> the record and clears changed attributes.
      def reload_with_dirty(*args) #:nodoc:
        record = reload_without_dirty(*args)
        changed_attributes.clear
        record
      end

      private
        # Map of change <tt>attr => original value</tt>.
        def changed_attributes
          @changed_attributes ||= {}
        end

        # Handle <tt>*_changed?</tt> for +method_missing+.
        def attribute_changed?(attr)
          changed_attributes.include?(attr)
        end

        # Handle <tt>*_change</tt> for +method_missing+.
        def attribute_change(attr)
          [changed_attributes[attr], __send__(attr)] if attribute_changed?(attr)
        end

        # Handle <tt>*_was</tt> for +method_missing+.
        def attribute_was(attr)
          attribute_changed?(attr) ? changed_attributes[attr] : __send__(attr)
        end

        # Handle <tt>reset_*!</tt> for +method_missing+.
        def reset_attribute!(attr)
          self[attr] = changed_attributes[attr] if attribute_changed?(attr)
        end

        # Handle <tt>*_will_change!</tt> for +method_missing+.
        def attribute_will_change!(attr)
          changed_attributes[attr] = clone_attribute_value(:read_attribute, attr)
        end

        # Wrap write_attribute to remember original attribute value.
        def write_attribute(attr, value)
          attr = attr.to_s

          # The attribute already has an unsaved change.
          if changed_attributes.include?(attr)
            old = changed_attributes[attr]
            changed_attributes.delete(attr) unless field_changed?(attr, old, value)
          else
            old = clone_attribute_value(:read_attribute, attr)
            changed_attributes[attr] = old if field_changed?(attr, old, value)
          end

          # Carry on.
          super(attr, value)
        end

        def update_with_dirty
          if partial_updates?
            # Serialized attributes should always be written in case they've been
            # changed in place.
            update_without_dirty(changed | (attributes.keys & self.class.serialized_attributes.keys))
          else
            update_without_dirty
          end
        end

        def field_changed?(attr, old, value)
          if column = column_for_attribute(attr)
            if column.number? && column.null && (old.nil? || old == 0) && value.blank?
              # For nullable numeric columns, NULL gets stored in database for blank (i.e. '') values.
              # Hence we don't record it as a change if the value changes from nil to ''.
              # If an old value of 0 is set to '' we want this to get changed to nil as otherwise it'll
              # be typecast back to 0 (''.to_i => 0)
              value = nil
            else
              value = column.type_cast(value)
            end
          end

          old != value
        end

      module ClassMethods
        def self.extended(base)
          class << base
            alias_method_chain :alias_attribute, :dirty
          end
        end

        def alias_attribute_with_dirty(new_name, old_name)
          alias_attribute_without_dirty(new_name, old_name)
          DIRTY_AFFIXES.each do |affixes|
            module_eval <<-STR, __FILE__, __LINE__+1
              def #{affixes[:prefix]}#{new_name}#{affixes[:suffix]}; self.#{affixes[:prefix]}#{old_name}#{affixes[:suffix]}; end  # def reset_subject!; self.reset_title!; end
            STR
          end
        end
      end
    end
  end
end
