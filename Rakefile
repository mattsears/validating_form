require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'spec/version'
require 'spec/rake/spectask'

desc 'Default: run unit tests.'
task :default => :spec

# Rspec setup
desc "Run all specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs with rcov"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_dir = 'coverage'
    t.rcov_opts = ['--exclude',
                   "spec\/spec,bin\/spec,examples,\.autotest,#{ENV['GEM_HOME']}"]
  end
end

desc 'Generate documentation for the validating_form_helper plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ValidatingFormHelper'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
