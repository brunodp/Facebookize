require 'bundler/cli'

module Facebookize
  module Generators
    class DelayedJobGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc "Installs Delayed Job"

      def install_delayed_job
        gem 'delayed_job'
        generate('delayed_job')
        rake('db:migrate')
      end
            
      # def show_readme
      #   readme "README" if behavior == :invoke
      # end
    end
  end
end