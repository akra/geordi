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
    long_desc <<-LONGDESC
    Check out a repository, `cd <repo>`, then let `setup` do the tiring work for
    you (all if applicable): bundle, create database.yml, create databases,
    migrate. If run with `--test`, it will execute `geordi test all` afterwards.
    LONGDESC
    def setup
      Rake::Task['geordi:create_databases'].invoke
      Rake::Task['geordi:migrate'].invoke
      run 'test:all' if options.test

      success 'Successfully set up the project.'
    end

    desc 'update', 'Bring a project up to date'
    option :test, :type => :boolean, :aliases => '-t', :desc => 'After updating, run tests'
    long_desc <<-LONGDESC
    Brings a project up to date. Bundle (if necessary), perform a `git pull` and
    migrate (if applicable), optionally run tests.
    LONGDESC
    def update
      Rake::Task['geordi:pull'].invoke
      Rake::Task['geordi:migrate'].invoke
      run 'test:all' if options.test

      success 'Successfully updated the project.'
    end

    desc 'migrate', 'Migrate all databases'
    long_desc <<-LONGDESC
    Runs `power-rake db:migrate` if parallel_tests does not exist in your
    `Gemfile`. Otherwise it runs migrations in your development environment and
    executes `b rake parallel:prepare` after that.
    LONGDESC
    def migrate
      Rake::Task['geordi:migrate']
    end

    desc 'devserver', 'Start a development server'
    option :port, :aliases => '-p', :default => '3000'
    def devserver
      Rake::Task['geordi:devserver'].invoke(options.port)
    end
    
    private
    
    def run(command)
      sub, command = command.split(':')
      invoke(sub, command, [], []) # weird API
    end

  end
end
