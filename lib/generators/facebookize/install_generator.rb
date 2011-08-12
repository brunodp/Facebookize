require 'bundler/cli'

module Facebookize
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Prepares Rails App for Facebook Dev"

      def remove_sqlite3_gem
        gsub_file 'Gemfile', "gem 'sqlite3'", ''
      end
      
      def add_gems
        gem 'koala'
        gem 'geoip'
        gem 'exception_notification'
        gem('sqlite3', :group => 'development')
        gem('capistrano', :group => 'development')
        gem('mysql', :group => 'production')
        if Gem.loaded_specs['rails'].version.to_s < '3.1'
          gem 'jquery-rails' 
        end
      end
            
      def run_bundle_and_generators
        Bundler::CLI.new.invoke(:update) # Para tener input CLI
        if Gem.loaded_specs['rails'].version.to_s < '3.1'
          generate("jquery:install", "") # "--ui" 
        end
      end
      
      def copy_files_and_add_routes
        copy_file "config/facebook.yml", "config/facebook.yml"
        copy_file "config/koala.rb", "config/initializers/koala.rb"
        copy_file "GeoIP.dat", "lib/GeoIP.dat"
        
        empty_directory "data"
        empty_directory "data/optins"
        copy_file "models/user.rb", "app/models/user.rb"
        
        copy_file "views/auth.html.erb", "app/views/users/auth.html.erb"
        copy_file "views/logged_in.html.erb", "app/views/users/logged_in.html.erb"
        
        copy_file "controllers/users_controller.rb", "app/controllers/users_controller.rb"
        
        route "match 'users/logged_in' => 'users#logged_in'"
        route "root :to => 'users#auth'"
        
        # Colorbox
        copy_file "colorbox/jquery.colorbox-min.js", "public/javascripts/jquery.colorbox-min.js"
        copy_file "colorbox/jquery.colorbox.js", "public/javascripts/jquery.colorbox.js"
        copy_file "colorbox/colorbox.css", "public/stylesheets/colorbox.css"
        directory "colorbox/colorbox", "public/images/colorbox"
        
        # Facebook Multifriend Select
        copy_file "facebook.multifriend.select/jquery.facebook.multifriend.select.min.js", 
                  "public/javascripts/jquery.facebook.multifriend.select.min.js"
        copy_file "facebook.multifriend.select/jquery.facebook.multifriend.select.js", 
                  "public/javascripts/jquery.facebook.multifriend.select.js"
        copy_file "facebook.multifriend.select/jquery.facebook.multifriend.select.css", 
                  "public/stylesheets/jquery.facebook.multifriend.select.css"
        
        # Images
        copy_file "images/fb_indicator.gif", "public/images/fb_indicator.gif"
        copy_file "images/grid_background.gif", "public/images/grid_background.gif"
        
        # Stylesheets
        copy_file "stylesheets/styles.css", "public/stylesheets/styles.css"
        copy_file "stylesheets/grid.css", "public/stylesheets/grid.css"
        copy_file "stylesheets/reset.css", "public/stylesheets/reset.css"
        copy_file "stylesheets/text.css", "public/stylesheets/text.css"
      end
      
      def config_exception_notification
        code_name = ask('Codename de proyecto (para los avisos por mail de Exception Notification)?')
        code_name = "DEFAULT" if code_name.blank?
        gsub_file 'config/environments/production.rb', 
                  '# Settings specified here will take precedence over those in config/application.rb', 
                  <<-DATA
# Settings specified here will take precedence over those in config/application.rb
  ActionMailer::Base.smtp_settings[:enable_starttls_auto] = false
  config.middleware.use ExceptionNotifier,
      :email_prefix => "[#{code_name}] ",
      :sender_address => %{"Exception Notification" <#{code_name}@marketingsur.com>},
      :exception_recipients => %w{lucas+apperrors@di-pentima.com.ar bruno+apperrors@di-pentima.com.ar}
      
                  DATA
      end
      
      def config_application_controller
        gsub_file 'app/controllers/application_controller.rb', 
                  'protect_from_forgery', 
                  <<-DATA
# protect_from_forgery

  def current_user
    session[:access_token]
  end

  def logged_in?
    if current_user.nil?
      redirect_to root_url
    end
  end
                  DATA

      end
      
      def config_application_layout
        gsub_file 'app/views/layouts/application.html.erb',
                  '<body>',
                  <<-DATA
<body>
  <div id="fb-root"></div>
  <script type="text/javascript" charset="utf-8">
    window.fbAsyncInit = function() {
      FB.init({
        appId: '<%= Facebook::APP_ID %>', 
        status: true, 
        cookie: true,
        xfbml: true
      });
    };
    (function() {
      var e = document.createElement('script'); e.async = true;
      e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
      document.getElementById('fb-root').appendChild(e);
    }());
  </script>
                DATA
      end
      
      # def show_readme
      #   readme "README" if behavior == :invoke
      # end
    end
  end
end