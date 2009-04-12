validating_form
====

A simple Rails form builder that evaluates the validation instructions on ActiveRecord objects with a little reflection and automatically mark those form fields as being required. In addition, it will append the validation's :message to the "title" of the form field so that your Javascript can display the same message without making a call to the server. Auto-labeling is also included with a few configuration options.

INSTALLATION
====

    script/plugin install git://github.com/mattsears/validating_form.git

USAGE
====

For the ActiveRecord objects, we define the validations normally:

    class User < ActiveRecord::Base
      validates_presence_of   :name, 	:message => "Your name is required"
      validates_presence_of   :gender, 	:message => "What is your gender?"
      validates_presence_of   :age, 	:message => "How old are you?"
    end

To create a form with validation, we define the form as follows:

    <% validating_form_for(:user, @user) do |f| %>
      <%= f.text_field(:name) %>
      <%= f.text_field(:gender) %>
      <%= f.text_field(:age)  %>
    <% end %>

That's it.  The validating_form builder will create the label and form fields as well as 'hints' for your Javascript knows how to validate:

    <form action="/users" id="user_form" method="post">
      <p>
        <label for="user_name">Name:</label><br />
        <input class="required" id="user_name" name="user[name]" title="Your name is required" type="text" />
      </p>
      <p>
         <label for="user_gender">Gender:</label><br />
         <input class="required" id="user_gender" name="user[gender]" title="What is your gender?" type="text" />
      </p>
      <p>
         <label for="user_age">Age:</label><br />
         <input class="required" id="user_age" name="user[age]" title="How old are you?" type="text" />
      </p>
     </form>

MISC
====

The validating_form helper will insert new html elements and attributes. You can customize the html output with the :label hash in each field:

    f.text_field(:name, :label => {})

    :after			# If true, inserts the <label> tag after the input field
    :text 			# Overrides the default label name
    :pargagraph		# if true, surrounds the form with a pagragragh (<p>)
    :linebreak		# if true, inserts a <br /> tag after the label


You can also specify global options when the application is initiated so that you don't need to specify the option in each field for the more common options.

    ActionView::Helpers::ValidatingFormBuilder.options = {:appendix => ":",
                                                      	  :default_class => {:text_field => "text",
                                                                             :select => "text"},
                                                          :linebreak => false }

    :appendix		# Appends a string after each label (<label>Name:</label>)
    :default_class	# Assigns a class to the field (<input class="text" name="user[name]" />)


CONTACT
====

    Author:     Matt Sears
    Email:      matt@mattsears.com
    Home Page:  http://mattsears.com
    License:    MIT Licence (http://www.opensource.org/licenses/mit-license.html)
