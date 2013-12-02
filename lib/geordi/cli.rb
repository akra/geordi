require 'thor'
require 'rake'
load File.expand_path('../tasks/geordi.rake', __FILE__)
require 'geordi/cli_test'

module Geordi
  class CLI < Thor
    
    register Geordi::CLITest, :test, 'test', 'Run tests'

    # fix help for subcommand 'test'
    Geordi::CLITest.class_eval <<-RUBY
      def help(command = nil, subcommand = false)
        subcommand ? self.class.command_help(shell, subcommand) : self.class.help(shell, false)
      end
    RUBY

    desc 'setup', 'Setup a project for the first time'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
    def setup
      Rake::Task['geordi:create_databases'].invoke
      Rake::Task['geordi:migrate'].invoke
      invoke :test if options.test
      
      success 'Successfully set up the project.'
    end
  
    desc 'update', 'Bring a project up to date'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
    def update
      Rake::Task['geordi:pull'].invoke
      Rake::Task['geordi:migrate'].invoke
      invoke :test if options.test
      
      success 'Successfully updated the project.'
    end
  
    desc 'migrate', 'Migrate all databases'
    def migrate
      Rake::Task['geordi:migrate'].invoke
    end
  
    # desc 'server [--port]', 'Start a development server'
    # desc 'console [ENV]', 'Open a console. Default: development locally, but also does the job of console-for'
    # desc 'shell ENV', 'shell-for'
    # desc 'dump [--load]', 'dump locally/remote [and load it]'

  end
end
