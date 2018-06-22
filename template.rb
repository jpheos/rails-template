`spring stop`
`rm Gemfile`

file 'Gemfile', <<-RUBY

source 'https://rubygems.org'

ruby '#{RUBY_VERSION}'

gem 'rails', '~> 5.1.6'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'awesome_print'
gem 'autoprefixer-rails', '~> 8.6'
gem 'devise', '~> 4.4.3'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.7'
  gem 'factory_bot_rails'
end

group :test do
  gem 'shoulda-matchers', '~> 3.1'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

RUBY

file 'Procfile', <<-YAML
web: bundle exec puma -C config/puma.rb
YAML


after_bundle do
  `bundle binstubs bundler --force`
  `bundle binstubs rspec-core`

  route "root to: 'application#home'"
  generate('rspec:install')
  generate('devise:install')
  generate('devise', 'User')

  rails_command 'db:drop db:create db:migrate'

  `rm spec/models/user_spec.rb`
  file 'spec/models/user_spec.rb', <<-RUBY
  require 'rails_helper'

  RSpec.describe User, type: :model do

    it { expect validate_presence_of(:email) }

    describe ".create" do
      let(:user) { create(:user) }
      subject { user.persisted? }

      it ".persisted? return true after create" do
        is_expected.to eq(true)
      end
    end
  end
  RUBY

  `rm spec/factories/users.rb`
  file 'spec/factories/users.rb', <<-RUBY
  FactoryBot.define do
    factory :user do
      sequence(:email) { |n| "email_\#{n}@example.com" }
      password 'azerty'
    end
  end
  RUBY

  inject_into_file 'spec/rails_helper.rb', "\n\tconfig.include FactoryBot::Syntax::Methods", :after => "RSpec.configure do |config|"

  append_to_file "spec/rails_helper.rb", <<-RUBY

# https://github.com/thoughtbot/shoulda-matchers
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library        :rails
  end
end
  RUBY


git :init
git add: '.'
git commit: "-am 'Initial commit'"


end

environment 'config.action_mailer.default_url_options = { host: \'localhost\', port: 3000 }', env: 'development'
environment 'config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }', env: 'production'

`rm app/controllers/application_controller.rb`

file 'app/controllers/application_controller.rb', <<-RUBY
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: [:home]

  def home

  end
end
RUBY

file 'app/views/application/home.html.erb', <<-ERB

  find me in <%= __FILE__ %>

ERB

`rm app/views/layouts/application.html.erb`
file 'app/views/layouts/application.html.erb', <<-ERB
<!DOCTYPE html>
<html>
  <head>
    <title>APPLICATION NAME</title>
    <%= csrf_meta_tags %>

    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <%= render "shared/navbar" %>
    <%= render "shared/flash_messages" %>
    <fieldset>
      <legend>YIELD LAYOUT</legend>
      <%= yield %>
    </fieldset>
    <%= render "shared/footer" %>
  </body>
</html>
ERB

file 'app/views/shared/_navbar.html.erb', <<-ERB
  <fieldset>
    <legend>NAVBAR</legend>
    find me in <%= __FILE__ %>
    <br/>
    <% if user_signed_in? %>
      <%= current_user.email %> <br/>
      <%= link_to('Logout', destroy_user_session_path, method: :delete) %>
    <% else %>
      <%= link_to('Sign in', new_user_session_path)  %> <br/>
      <%= link_to('Sign up', new_user_registration_path)  %>
    <% end %>
  </fieldset>
ERB


file 'app/views/shared/_flash_messages.html.erb', <<-ERB
  <fieldset>
    <legend>FLASH MESSAGE</legend>
    <p class="notice"><%= notice %></p>
    <p class="alert"><%= alert %></p>
  </fieldset>
ERB

file 'app/views/shared/_footer.html.erb', <<-ERB
  <fieldset>
    <legend>FOOTER</legend>
    find me in <%= __FILE__ %>
  </fieldset>
ERB
