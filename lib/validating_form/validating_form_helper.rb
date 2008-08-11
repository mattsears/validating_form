module ActionView #:nodoc:
  module Helpers #:nodoc:
    # Provides labeling and client-side validation for the Rails form helpers. This helper evaluates the ActiveRecord
    # object to determine which attributes need validation based on the ActiveRecord::Validations::ClassMethods 
    # (e.g., validates_presence_of, validates_numericality_of, validates_size_of, and so on). defined for the object. 
    # The helper generates 'hints' inside the HTML for the Javascript (validating_form.js) to check the form for valid
    # entries when the form is submitte. (i.e., when the user hits the submit button the +validate()+ is called via JavaScript).
    #
    # TODO:
    #  - Refactor code to handle select tags cleaner
    #  - Test in the installation procedures
    module ValidatingFormHelper
      # Wrapper for form_for, except we add labeling and validations hints for client-side validation.  
      # Labels are named after the attribute name by default, but can be overridden in the options.
      #
      # An options hash can be specified to override the default behaviors. Any other supplied parameters are passed along to form_for.
      # For example, we can create the normal validations for an ActiveRecord object like this:
      #
      #   class User < ActiveRecord::Base
    	#     validates_presence_of   :name, 	:message => "Your name is required"
    	#     validates_presence_of   :age, 	:message => "How old are you?"
    	#     ...
    	#   end
      # 
      # ... the form could look like this...
      #
      #   <% validating_form_for @user, do |f| %>
      #     <%= f.text_field :name %>
      #     <%= f.text_field :age %>
      #     ...
      #   <% end %>
      #
      # ...becomes...
      #
      #   <form action="/users" id="user_form" method="post" onsubmit="var valid = new Validation('user_form'); return valid.validate();">
    	#	    <p>
      #			  <label for="user_name">Name:</label><br />
      #  			<input class="required" id="user_name" name="user[name]" title="Your name is required" type="text" />
    	#	    </p>
    	#	    <p>
    	#		    <label for="user_age">Age:</label><br />
    	#		    <input class="required" id="user_age" name="user[age]" title="How old are you?" type="text" />
    	#	    </p>
    	#   </form>
      # 
      def validating_form_for(record_or_name_or_array, *args, &proc)
        options = extract_options!(args, record_or_name_or_array)
        # Remove any nils if we received an array, this allows for common forms to be built
        # that can be used for both edit and new actions but that don't require the edit action
        # to be nested within a parent resource
        record_or_name_or_array.reject! {|a| a.nil? } if record_or_name_or_array.is_a? Array
        # Now build the form
        form_for(record_or_name_or_array, *(args << options), &proc)
      end

      # Works similarly to fields_for, except we add labeling and validation hints for client-side validation.
      #
      # ==== Examples
      #
      #   <% validating_form_for @user do |user_form| %>
      #     <%= user_form.text_field :name %>
      #     <%= user_form.text_field :age %>
      #
      #     <% validating_fields_for @user.address do |address_fields| %>
      #       <%= address_fields.text_field :street %>
      #     <% end %>
      #   <% end %>
      #
      def validating_fields_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        fields_for(record_or_name_or_array, *(args << options.merge(:builder => ActionView::Helpers::ValidatingFormBuilder)), &proc)
      end

      private

      def extract_options!(args, object_name)
        options = args.extract_options!
        options.merge(:builder => ActionView::Helpers::ValidatingFormBuilder,
        :html => extract_html_options!(options, object_name))
      end

      def extract_html_options!(options, object_name)
        html_options = options[:html] || {}
        html_options[:id] = "#{object_name}_form" if html_options[:id].nil?
        html_options[:onsubmit] = "var valid = new Validation('#{html_options[:id]}'); return valid.validate();"
        html_options
      end

    end
  end
end
