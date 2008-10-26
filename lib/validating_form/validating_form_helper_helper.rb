module ValidatingFormHelperHelper #:nodoc:

  private

  ##
  # Generates the input and label tags
  def render_tag_with_label(label, unlabeled_tag, template = self)
    label_html = extract_label_html! label
    label_text = extract_label_text! label
    label_template = template.content_tag(:label, label_text, label_html)
    label_and_tag = ""

    if label[:after] == true
      label_and_tag = unlabeled_tag + label_template
    elsif label[:linebreak] == false
      label_and_tag = label_template + unlabeled_tag
      label_and_tag <<  template.content_tag(:span, " #{label[:after]}") unless label[:after].blank?
    else
      label_and_tag = label_template + "<br />" + unlabeled_tag 
    end

    if label[:paragraph] == false || label[:after] == true
      return label_and_tag
    else
      return template.content_tag(:p, label_and_tag)
    end
    
  end

  def extract_label_options!(options, global_options, builder = false) #:nodoc:
    label = options.delete :label

    if (label.nil? and !builder) or (false == label)
      return false
    end

    # From here on, we need a Hash..
    label = case label
    when Hash     then label
    when String   then { :text => label }
    when nil, true then {}
    end

    # Per the HTML spec..
    label[:for] = options[:id]

    # the label options take presedence over the global options
    global_options.merge(label)
  end

  def extract_tag_options!(object, object_name, helper, field, options = {}, global_options = {})

    tag_options  = {}
    tag_options["title"] = message_for(object_name, field)
    tag_class = "#{options[:class]}"

    # Append 'required' hints to the class attribute
    if required_field?(object_name, field) && satisfies_conditions?(object, object_name, field) && options[:validates].blank?
      tag_class << " required"
    end

    # Does the field require confirmation of another field?
    if has_confirmation_field?(object_name, field)
      tag_class << " confirmation"
    end

    if validates = options.delete(:validates)
      tag_class << " #{validates}"
    end

    # Append the default class from the global options
    if global_options.has_key?(:default_class) && !options.has_key?(:class)
      tag_class << default_class_for(helper, global_options[:default_class])
    end

    tag_style = "#{options[:style]}"
    if width = options.delete(:width)
      tag_style << "width:#{width}px;"
    end

    tag_options["style"] = tag_style.strip unless tag_style.blank?
    tag_options["class"] = tag_class.strip unless tag_class.blank?
    tag_options.merge(options)
  end

  def extract_label_html!(label) #:nodoc:
    [:id, :class, :for].inject({}) { |html,k| html.merge k => label.delete(k) }
  end

  def extract_label_text!(label)
    label_text = label[:text] || ""
    if label.include?(:appendix)
      label_text << label[:appendix]
    end
    label_text
  end

  def check_or_radio?(helper) #:nodoc:
    [:check_box_tag, :radio_button_tag].include? helper.to_sym
  end

  def default_class_for(helper, default_classes)
    " #{default_classes[helper.to_sym]}"
  end

  ##
  # Get message from the validation instructions
  def message_for(object_name, field)
    if constantizable?(object_name)
      object_name.to_s.camelize.constantize.validation_message_for(field)
    end
  end

  ##
  # Check if the field is required according to the Model's validation instructions
  def required_field?(object_name, field)
    if constantizable?(object_name)
      object_name.to_s.camelize.constantize.required_field?(field)
    end
  end

  ##
  # Check if the field requires the confirmation of the another field
  def has_confirmation_field?(object_name, field)
    if constantizable?(object_name)
      object_name.to_s.camelize.constantize.has_confirmation_field?(field)
    end
  end

  ##
  # Evaluate the 'if' condition specified in the validaitons
  def satisfies_conditions?(object, object_name, field)
    return false unless constantizable?(object_name)
    
    condition = object_name.to_s.camelize.constantize.if_condition_for(field)
    if condition.nil? || object.nil?
      return true
    else
      return object.send(condition)
    end
  end

  ##
  # Make sure we can contantize an object given the object's name
  def constantizable?(name)
    begin
      name.to_s.camelize.constantize
      return true
    rescue
      return false
    end
  end

end
