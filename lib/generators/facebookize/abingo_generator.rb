require 'bundler/cli'

module Facebookize
  module Generators
    class AbingoGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Installs Abingo"

      def install_abingo
        plugin('abingo', :git => 'git://git.bingocardcreator.com/abingo.git')
        generate('abingo_migration')
        rake('db:migrate')
      end
      
      def add_abingo_id_method
        gsub_file 'app/controllers/application_controller.rb', 
                  'protect_from_forgery', 
                  <<-DATA
protect_from_forgery

  before_filter :set_abingo_identifier

  def set_abingo_identifier
    if request.user_agent =~ /\b(Baidu|Gigabot|Googlebot|libwww-perl|lwp-trivial|msnbot|SiteUptime|Slurp|WordPress|ZIBB|ZyBorg)\b/i
      Abingo.identity = "robot"
    elsif session[:me]
      Abingo.identity = session[:me][:id]
    else
      session[:abingo_identity] ||= rand(10 ** 10).to_i.to_s
      Abingo.identity = session[:abingo_identity]
    end
  end

                  DATA
      end
      
      def setup_production_cache
        gsub_file 'config/environments/production.rb', 
                  '# Settings specified here will take precedence over those in config/application.rb', 
                  <<-DATA
# Settings specified here will take precedence over those in config/application.rb
  
  # Para A/Bingo
  config.cache_store = :file_store, "\#{Rails.root}/tmp/cache"
  
                  DATA
      end
      
      def install_abingo_dashboard
        copy_file "controllers/abingo_dashboard_controller.rb", "app/controllers/abingo_dashboard_controller.rb"
        route "match 'abingo(/:action(/:id))', :to => 'abingo_dashboard', :as => :abingo"
      end
            
      # def show_readme
      #   readme "README" if behavior == :invoke
      # end
    end
  end
end