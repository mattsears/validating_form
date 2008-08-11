class User < ActiveRecord::Base
  validates_presence_of   :name, :message => "name is required"
  validates_presence_of   :gender, :message => "gender is required"
  validates_presence_of   :age, :message => "age is required"
  validates_inclusion_of  :status, :in => ['new', 'old']
end
