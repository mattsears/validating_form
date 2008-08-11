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
  ['/public/javascripts', '/public/stylesheets'].each do |dir|
    source = File.join(directory,dir)
    dest = RAILS_ROOT + dir
    FileUtils.mkdir_p(dest)
    FileUtils.cp(Dir.glob(source+'/*.*'), dest)
  end
end

