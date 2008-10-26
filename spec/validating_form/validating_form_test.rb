require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../models'

describe "validating form helpers" do
  
    describe "generating a default label from a form builder" do
    
      before do
        template = <<-EOF
          <% validating_form_for(:user, @user) do |f| %>
          <%= f.text_field(:name) %>
          <% end %>
        EOF
        @form = render(template, 'user')
      end
    
      it "should generate a label tag using the string as the label" do
        @form.should have_tag('//label').with_text('Name')
      end
      
      it "should generate a <br/> tag after the label by default" do
        @form.should match(%r(</label><br />))
      end
      
      it "should by default separate each label and tag with a paragraph <p>" do
        @form.should match(%r(<p><label))
      end
      
    end
    
    describe "generating a label with options" do
        
        before do
          template = <<-EOF
            <% validating_form_for(:user, @user) do |f| %>
            <%= f.text_field(:name, :label => {:after => true}, :class => "foo") %>
            <%= f.text_field(:login, :label => {:after => true, :text => "Username"}, :width => 100, :class => "foo") %>
            <%= f.text_field(:gender, :label => {:paragraph => false }, :style => "height:25px") %>
            <% end %>
          EOF
          @form = render(template, 'user')
        end
        
        it "should generate a label after the form field" do
           @form.should match(%r(Name</label>))
        end
        
        it "should respect the :class attribute" do
           @form.should have_tag("//input").with_attribute("class").with_value("foo required")
        end
        
        it "should not generate the <br /> tag since the label comes after the tag" do
          @form.should_not match(%r(Name</label><br />))
        end
        
        it "should generate a form id if one wasn't provided" do
          @form.should match(%r(<form.+id="user_form"[^>]*>))
        end
        
        it "should override the field name with the given :text attribute" do
          @form.should have_tag('//label[2]').with_text('Username')
        end
        
        it "should not generate a paragraph (<p>) when :paragraph attribute is set to false" do
          @form.should_not match(%r(<p><label for=\"user_gender\">Gender</label>))
        end
        
        it "should keep the style attribute intact" do
          @form.should_not have_tag("//input[@id='user_login']").with_attribute("style").with_value("500px;")
        end
        
        it "should assign a width to the style attribue" do
          @form.should have_tag("//input[@id='user_login']").with_attribute("style").with_value("width:100px;")
        end
        
      end
      
      describe "generating a label and tag with global options" do
        
        before do
          ActionView::Helpers::ValidatingFormBuilder.options = {:appendix => ":", 
                                                                :default_class => {:text_field => "text", 
                                                                                   :select => "text"},
                                                                :linebreak => false,
                                                                :advice => :after}
          template = <<-EOF
            <% validating_form_for(:user, @user) do |f| %>
              <%= f.text_field(:name) %>
              <%= f.text_field(:phone, :label => {:linebreak => true}) %>
              <%= f.select(:gender, [['Male', 'male'], ['Female', 'female']]) %>
              <%= f.text_field(:age, :class => 'shorttext') %>
            <% end %>
          EOF
          @form = render(template)
        end
        
        it "should generate a label with ':' appended at the end" do
          @form.should match(%r(Name:</label>))
        end
        
        it "should append a default 'class' attribute to the tag" do
          @form.should match(%r(<input.+class="required text"[^>]*>))
        end
        
        it "should append a default 'class' attribute to the select tag" do
          @form.should have_tag("//select[@id='user_gender']").with_attribute("class").with_value("required text")
        end
        
        it "should not append line breaks <br /> after the label" do
          @form.should_not match(%r(Name:</label><br />))
        end
        
        it "should override the global option for :linebreak if given in the label" do
          @form.should match(%r(Phone:</label><br />))
        end
        
        it "should override the :default_class option when specified in the tag options" do
          @form.should match(%r(Age:</label><input.+class="shorttext required"[^>]*>))
        end
        
        after(:each) do
            ActionView::Helpers::ValidatingFormBuilder.options = {}
        end
      end
      
      describe "generating a label and tag with validation" do
       
        before do
          template = <<-EOF
            <% validating_form_for(:user, @user, :html => {:id => 'user_form'}) do |f| %>
            <%= f.text_field(:name, :class => "text") %>
            <%= f.text_field(:phone, :class => "text") %>
            <%= f.select(:gender, [['Male', 'male'], ['Female', 'femail']]) %>
            <%= f.text_field(:custom, :validates => "validates-custom") %>
            <% end %>
          EOF
          @form = render(template, 'user')
        end   
        
        it "should add the validation message to the tag if exists" do
          @form.should match(%r(<input.+title="name is required"[^>]*>))
        end
        
        it "should add validation message to the 'gender' select tag" do
          @form.should have_tag("//select[@id='user_gender']").with_attribute("title").with_value("gender is required")
        end
        
        it "should not append anything to the :class attribue if it's not a required field" do
          @form.should match(%r(<input.+class="text"[^>]*>))
        end
        
        it "should append 'required' in the 'class' attribute" do
          @form.should match(%r(<input.+class="text required"[^>]*>))
        end
        
        it "should respect the form options set the by the user" do
          @form.should match(%r(<form.+id="user_form"[^>]*>))
        end
        
        it "should have 'onsubmit' instructions appended to the form tag" do
          @form.should match(%r(<form.+onsubmit=[^>]*>))
        end
        
        it "should add custom validation instruction to the class attribute" do
          @form.should have_tag("//input[@id='user_custom]").with_attribute("class").with_value("validates-custom")
        end
        
      end
    
    describe "generating validation hints with a different object name of the object itself" do
      before do
        user = User.new(:name => "Bob", :phone => "5551234", :crypted_password => "secret")
        template = <<-EOF
          <% validating_fields_for('account[user]', @var, :html => {:id => 'user_form'}) do |f| %>
            <%= f.text_field(:name) %>
            <%= f.text_field(:phone) %>
            <%= f.password_field(:password) %>
            <%= f.password_field(:password_confirmation) %>
          <% end %>
        EOF
        @form = render(template, user)
      end
      
      it "should require the user's name" do
         @form.should have_tag("//input[@id='account_user_name']").with_attribute("class").with_value("required")
      end
      
      it "should not require the password field since it's already been filled in" do
        @form.should_not have_tag("//input[@id='account_user_password_confirmation']").with_attribute("class").with_value("required")
      end
      
      it "should not require the password field since it's blank" do
        @form.should_not have_tag("//input[@id='account_user_password']").with_attribute("class").with_value("required")
      end
      
    end

end
