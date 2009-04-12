require File.dirname(__FILE__) + '/../spec_helper'

describe "validating form helpers" do

  describe "generating a default label from a form builder" do

    before do
      template = <<-EOF
        <% validating_form_for(:user, @user) do |f| %>
        <%= f.text_field(:name) %>
        <% end %>
      EOF
      @tag = render(template, 'user')
    end

    it "should generate a label tag using the string as the label" do
      @tag.should have_tag('//label').with_text('Name')
    end

    it "should generate a <br/> tag after the label by default" do
      @tag.should match(%r(</label><br />))
    end

    it "should by default separate each label and tag with a paragraph <p>" do
      @tag.should match(%r(<p><label))
    end

  end

  describe "generating a label with options" do

    before do
      template = <<-EOF
        <% validating_form_for(:user, @user) do |f| %>
        <%= f.text_field(:name, :label => {:after => true}, :class => "foo") %>
        <%= f.text_field(:login, :label => {:after => true, :text => "Username"}, :class => "foo") %>
        <%= f.text_field(:gender, :label => {:paragraph => false }, :style => "height:25px") %>
        <% end %>
      EOF
      @tag = render(template, 'user')
    end

    it "should generate a label after the form field" do
       @tag.should match(%r(Name</label>))
    end

    it "should respect the :class attribute" do
      @tag.should match(%r(<input.+class="foo required"[^>]*>))
    end

    it "should not generate the <br /> tag since the label comes after the tag" do
      @tag.should_not match(%r(Name</label><br />))
    end

    it "should override the field name with the given :text attribute" do
      @tag.should have_tag('//label[2]').with_text('Username')
    end

    it "should not generate a paragraph (<p>) when :paragraph attribute is set to false" do
      @tag.should_not match(%r(<p><label for=\"user_gender\">Gender</label>))
    end

    it "should keep the style attribute intact" do
      @tag.should match(%r(<input.+style="height:25px"[^>]*>))
    end

  end

  describe "generating a label and tag with global options" do

    before do
      ActionView::Helpers::ValidatingFormBuilder.options = {:appendix => ":",
                                                            :default_class => {:text_field => "text",
                                                                               :select => "text"},
                                                            :linebreak => false }
      template = <<-EOF
        <% validating_form_for(:user, @user) do |f| %>
          <%= f.text_field(:name) %>
          <%= f.text_field(:phone, :label => {:linebreak => true}) %>
          <%= f.select(:gender, [['Male', 'male'], ['Female', 'female']]) %>
          <%= f.text_field(:age, :class => 'shorttext') %>
        <% end %>
      EOF
      @tag = render(template)
    end

    it "should generate a label with ':' appended at the end" do
      @tag.should match(%r(Name:</label>))
    end

    it "should append a default 'class' attribute to the tag" do
      @tag.should match(%r(<input.+class="required text"[^>]*>))
    end

    it "should append a default 'class' attribute to the select tag" do
      @tag.should match(%r(<select.+class="required text"[^>]*>))
    end

    it "should not append line breaks <br /> after the label" do
      @tag.should_not match(%r(Name:</label><br />))
    end

    it "should override the global option for :linebreak if given in the label" do
      @tag.should match(%r(Phone:</label><br />))
    end

    it "should override the :default_class option when specified in the tag options" do
      @tag.should match(%r(Age:</label><input.+class="shorttext required"[^>]*>))
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
        <% end %>
      EOF
      @tag = render(template, 'user')
    end

    it "should add the validation message to the tag if exists" do
      @tag.should match(%r(<input.+title="name is required"[^>]*>))
    end

    it "should add validation message to the 'gender' select tag" do
      @tag.should match(%r(<select.+title="gender is required"[^>]*>))
    end

    it "should not append anything to the :class attribue if it's not a required field" do
      @tag.should match(%r(<input.+class="text"[^>]*>))
    end

    it "should append 'required' in the 'class' attribute" do
      @tag.should match(%r(<input.+class="text required"[^>]*>))
    end

    it "should respect the form options set the by the user" do
      @tag.should match(%r(<form.+id="user_form"[^>]*>))
    end

  end

end
