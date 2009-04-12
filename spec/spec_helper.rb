$:.unshift(File.dirname(__FILE__))
$:.unshift(File.join(File.dirname(__FILE__), '../lib'))

require 'test/unit'
require 'ostruct'
require 'rubygems'
require 'spec'
require 'hpricot'
require 'action_controller'
require 'action_controller/test_process'
require 'action_view'
require 'active_record'
require 'active_record/fixtures'

RAILS_ROOT = File.join(File.dirname(__FILE__), '..') unless defined? AERIAL_ROOT
ActiveRecord::Base.configurations['test'] = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'][ENV['DB'] || 'sqlite3'])
ActionController::Base.view_paths = [File.join(File.dirname(__FILE__), 'views')]

require File.join(File.dirname(__FILE__), '../init')

load(File.dirname(__FILE__) + "/schema.rb") if File.exist?(File.dirname(__FILE__) + "/schema.rb")

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

class TestController < ActionController::Base

  attr_accessor :template_string, :var

  def rescue_action (e)
    raise e
  end

  def test
    render :inline => template_string
  end

end

module ValidationTestCases

  class ValidationTest < ActionController::TestCase

    FIXTURE_LOAD_PATH = File.join(File.dirname(__FILE__), '/fixtures')

    def initialize(template, var = nil)
      @template = template
      @var      = var
    end

    def render
      @controller  = TestController.new
      @request  = ActionController::TestRequest.new
      @response  = ActionController::TestResponse.new
      @controller.template_string = @template
      @controller.var = @var.is_a?(Hash) ? OpenStruct.new(@var) : @var
      get :test
      @response.body
    end

  end

  def render(template, var = nil)
    v = ValidationTest.new(template, var)
    v.render
  end

end

module TagMatchers

  class TagMatcher

    def initialize (expected)
      @expected = expected
      @text     = nil
    end

    def with_text (text)
      @text = text
      self
    end

    def matches? (target)
      @target = target
      doc = Hpricot(target)
      @elem = doc.at(@expected)
      @elem && (@text.nil? || @elem.inner_html == @text)
    end

    def failure_message
      "Expected #{match_message}"
    end

    def negative_failure_message
      "Did not expect #{match_message}"
    end

    protected

    def match_message
      if @elem
        "#{@elem.to_s.inspect} to have text #{@text.inspect}"
      else
        "#{@target.inspect} to contain element #{@expected.inspect}"
      end
    end

  end

  def have_tag (expression)
    TagMatcher.new(expression)
  end

end

Spec::Runner.configure do |config|
  config.include TagMatchers
  config.include ValidationTestCases
end

require 'validating_form/validating_form_builder'
require 'schema'
require 'models'

