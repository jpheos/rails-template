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
  route "root to: 'application#home'"
  generate('devise:install')
  generate('devise', 'User')

  rails_command 'db:drop db:create db:migrate'
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
    <%= yield %>
    <%= render "shared/footer" %>
  </body>
</html>
ERB

file 'app/views/shared/_navbar.html.erb', <<-ERB
  <fieldset>
    <legend>NAVBAR</legend>
    find me in <%= __FILE__ %>
    <% if user_signed_in? %>
      <%= current_user.email %> <br>
      <%= link_to('Logout', destroy_user_session_path, method: :delete) %>
    <% else %>
      <%= link_to('Login', new_user_session_path)  %>
    <% end %>
  </fieldset>
ERB


file 'app/views/shared/_flash_messages.html.erb', <<-ERB
  <p class="notice"><%= notice %></p>
  <p class="alert"><%= alert %></p>
ERB

file 'app/views/shared/_footer.html.erb', <<-ERB
  <fieldset>
    <legend>FOOTER</legend>
    find me in <%= __FILE__ %>
  </fieldset>
ERB

git :init
git add: '.'
git commit: "-m 'Initial commit"
