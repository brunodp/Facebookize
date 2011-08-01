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
        gem 'paperclip'
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
      
      # def show_readme
      #   readme "README" if behavior == :invoke
      # end
    end
  end
end