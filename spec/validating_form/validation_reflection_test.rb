require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../models'

describe "reflecting on validation" do
  
  describe User, "calling required_field?" do
    
    it "should determine if a field is required " do
      User.required_field?(:name).should == true
    end
    
    it "should return false if a field is not required" do
      User.required_field?(:phone).should == false
    end
    
  end

  describe User, "required field" do

    it "should require a field with validates_presence_of" do
      User.should be_required_field(:name)
    end

    it "should require a field with validates_inclustion_of" do
      User.should be_required_field(:status)
    end

    it "should not require a field with validates_inclusion_of where blank is allowed" do
      User.should_not be_required_field(:optional_status)
    end

    it "should not require a field with validates_inclusion_of where nil is allowed" do
      User.should_not be_required_field(:optional_status_2)
    end

    it "should not require a field with an :if option" do
      User.should_not be_required_field(:conditional_field)
    end

    it "should not require a field with an :on option not set to :create" do
      User.should_not be_required_field(:on_update_field)
    end

  end
  
  describe User, "calling validation_message_for" do
    
    it "should determine if a message is included on the validaton" do
      User.validation_message_for(:name).should == "name is required"
    end
    
    it "should return nil if not message exists" do
      User.validation_message_for(:on_update_field).should be_nil
    end
    
  end
  
  describe User, "calling if_condition_for" do
    it "should return the condition method" do
      User.if_condition_for(:password_confirmation).should == :password_required?
    end
    
  end
  
end

