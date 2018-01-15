require_relative 'config/application'

Rails.application.load_tasks

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop)

  RSpec::Core::RakeTask.new(:spec) do |t|
    test_output = File.join(ENV.fetch('CIRCLE_TEST_REPORTS', 'tmp'), 'rspec', 'junit.xml')
    t.rspec_opts = %W(-f JUnit -o #{test_output})
  end

  task 'print_schema' => :environment do
    require 'graphql/schema/printer'
    puts GraphQL::Schema::Printer.new(RootSchema).print_schema
  end

  task default: [:rubocop, :spec]
end
