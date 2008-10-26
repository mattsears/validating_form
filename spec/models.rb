class User < ActiveRecord::Base
  
  attr_accessor :password_confirmation, :password, :crypted_password
  
  validates_presence_of   :name,    :message => "name is required"
  validates_presence_of   :gender,  :message => "gender is required"
  validates_presence_of   :age,     :message => "age is required"
  validates_inclusion_of  :status,  :in => ['new', 'old']
  validates_presence_of   :password, :if => :password_required?
  validates_presence_of   :password_confirmation, :message => "passwords must match", :if => :password_required?
  
  protected 
  
  def password_required?
    crypted_password.blank? or not password.blank?
  end
  
end
