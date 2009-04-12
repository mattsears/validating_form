require 'validating_form/validating_form_helper_helper'

module ActionView #:nodoc:
  module Helpers #:nodoc:

    class ValidatingFormBuilder < ActionView::Helpers::FormBuilder
      include ValidatingFormHelperHelper

      @@options = {}
      cattr_accessor :options

      # A list of supported helpers
      def self.helpers
        ((field_helpers) - %w(form_for fields_for hidden_field file_field field_set ))
      end

      helpers.each do |helper|
        define_method helper do |field, *args|
          options = args.last.is_a?(Hash) ? args.last : {}
          label = extract_label_options! options, @@options, true
          tag_options = extract_tag_options!(@object_name, helper, field, options, @@options)
          unlabeled_tag = super(field, tag_options)
          return unlabeled_tag if false == label
          label[:for]  ||= extract_for unlabeled_tag
          label[:text] ||= field.to_s.humanize
          render_tag_with_label label, unlabeled_tag, @template
        end
      end

      def select(field, choices, options={}, html_options={})
        label = extract_label_options! options, @@options, true
        tag_options = extract_tag_options!(@object_name, "select", field,  html_options, @@options)

        unlabeled_tag = super(field, choices, options, tag_options)
        return unlabeled_tag if false == label
        label[:for]  ||= extract_for unlabeled_tag
        label[:text] ||= field.to_s.humanize
        render_tag_with_label label, unlabeled_tag, @template
      end

      def country_select(field, choices, options={}, html_options={})
        label = extract_label_options! options, @@options, true
        tag_options = extract_tag_options!(@object_name, "country_select", field,  html_options, @@options)
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
