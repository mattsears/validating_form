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

# install files
unless File.exists?(RAILS_ROOT + '/public/javascripts/validating_form.js')
    dir = '/public/javascripts/'
    source = File.join(directory, dir)
    dest = RAILS_ROOT + dir
    FileUtils.cp(Dir.glob(source+'/*.*'), dest)
  end
end
