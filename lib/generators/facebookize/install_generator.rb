require 'bundler/cli'

module Facebookize
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Prepares Rails App for Facebook Dev"

      def add_gems
        gem 'koala'
        gem 'geoip'
        if Gem.loaded_specs['rails'].version.to_s < '3.1'
          gem 'jquery-rails' 
        end
        gem 'exception_notification'
      end
            
      def run_bundle_and_generators
        Bundler::CLI.new.invoke(:update)
        if Gem.loaded_specs['rails'].version.to_s < '3.1'
          generate("jquery:install", "") # "--ui" 
        end
      end
      
      def copy_files_and_add_routes
        copy_file "facebook.yml", "config/facebook.yml"
        copy_file "koala.rb", "config/initializers/koala.rb"
        copy_file "GeoIP.dat", "lib/GeoIP.dat"
        
        empty_directory "data"
        empty_directory "data/optins"
        copy_file "user.rb", "app/models/user.rb"
        
        copy_file "auth.html.erb", "app/views/users/auth.html.erb"
        copy_file "logged_in.html.erb", "app/views/users/logged_in.html.erb"
        
        copy_file "users_controller.rb", "app/controllers/users_controller.rb"
        
        route "match 'users/logged_in' => 'users#logged_in'"
        route "root :to => 'users#auth'"
        
        # Colorbox
        copy_file "jquery.colorbox-min.js", "public/javascripts/jquery.colorbox-min.js"
        copy_file "jquery.colorbox.js", "public/javascripts/jquery.colorbox.js"
        copy_file "colorbox.css", "public/stylesheets/colorbox.css"
        directory "colorbox", "public/images/colorbox"
        
        # Facebook Multifriend Select
        copy_file "jquery.facebook.multifriend.select.min.js", 
                  "public/javascripts/jquery.facebook.multifriend.select.min.js"
        copy_file "jquery.facebook.multifriend.select.js", "public/javascripts/jquery.facebook.multifriend.select.js"
        copy_file "jquery.facebook.multifriend.select.css", "public/stylesheets/jquery.facebook.multifriend.select.css"
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
      
      # def show_readme
      #   readme "README" if behavior == :invoke
      # end
    end
  end
end