require_relative 'config/application'

Rails.application.load_tasks

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop)

  Rake::Task[:spec].clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    test_output = File.join(ENV.fetch('CIRCLE_TEST_REPORTS', 'tmp'), 'rspec', 'junit.xml')
    t.rspec_opts = %W[--format progress --format JUnit --out #{test_output}]
  end

  task 'print_schema' => :environment do
    require 'graphql/schema/printer'
    puts GraphQL::Schema::Printer.new(RootSchema).print_schema
  end

  Rake::Task[:default].clear
  task default: [:rubocop, :spec]
end
