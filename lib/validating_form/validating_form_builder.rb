require 'validating_form/validating_form_helper_helper'

module ActionView #:nodoc:
  
  class Base
    # Change the default behavior of the 'fieldWithErrors' div tag to use span instead
    @@field_error_proc = Proc.new{ |html_tag, instance| "<span class=\"fieldWithErrors\">#{html_tag}</span>" }
    cattr_accessor :field_error_proc
  end
  
  module Helpers #:nodoc:

    class ValidatingFormBuilder < ActionView::Helpers::FormBuilder
      include ValidatingFormHelperHelper

      @@options = {}
      cattr_accessor :options

      ##
      # A list of supported h+elpers
      def self.helpers
        ((field_helpers) - %w(form_for fields_for hidden_field file_field field_set))
      end

      helpers.each do |helper|
        define_method helper do |field, *args|
          # Try to get the real object first, otherwise settle for the form name
          form_object = object.nil? ? object_name : object.class.to_s.chomp.downcase.to_sym
          options = args.last.is_a?(Hash) ? args.last : {}
          label = extract_label_options! options, @@options, true
          tag_options = extract_tag_options!(object, form_object, helper, field, options, @@options)
          unlabeled_tag = super(field, tag_options)
          return unlabeled_tag if false == label
          label[:for]  ||= extract_for unlabeled_tag
          label[:text] ||= field.to_s.humanize
          render_tag_with_label label, unlabeled_tag, @template
        end
      end

      def select(field, choices, options={}, html_options={})
        form_object = object.nil? ? object_name : object.class.to_s.chomp.downcase.to_sym
        label = extract_label_options! options, @@options, true
        tag_options = extract_tag_options!(object, form_object, "select", field,  html_options, @@options)
        unlabeled_tag = super(field, choices, options, tag_options)
        return unlabeled_tag if false == label
        label[:for]  ||= extract_for unlabeled_tag
        label[:text] ||= field.to_s.humanize
        render_tag_with_label label, unlabeled_tag, @template
      end

      def country_select(field, choices, options={}, html_options={})
        label = extract_label_options! options, @@options, true
        tag_options = extract_tag_options!(object, @object_name, "country_select", field,  html_options, @@options)
        unlabeled_tag = super(field, choices, options, tag_options)
        return unlabeled_tag if false == label
        label[:for]  ||= extract_for unlabeled_tag
        label[:text] ||= field.to_s.humanize
        render_tag_with_label label, unlabeled_tag, @template
      end

      private

      def extract_for(tag)
        tag[/id="([^"]+)"/, 1]
      end

    end

  end
end
