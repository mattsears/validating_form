require 'validating_form'

class ActionView::Base
  include ValidatingFormHelperHelper
end

ActiveRecord::Base.class_eval do
  include ValidationReflection
end

ActionView::Base.class_eval do
  include ActionView::Helpers::ValidatingFormHelper
end