# frozen_string_literal: true

require_relative 'config/application'
require 'graphql/rake_task'

Rails.application.load_tasks

GraphQL::RakeTask.new(schema_name: 'RootSchema', idl_outfile: '_schema.graphql')

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop)

  task 'print_schema' => :environment do
    require 'graphql/schema/printer'
    puts GraphQL::Schema::Printer.new(RootSchema).print_schema
  end

  desc 'run prettier check'
  task prettier_check: :environment do
    system 'yarn run prettier-check'
    abort 'prettier-check failed' unless $CHILD_STATUS.exitstatus.zero?
  end

  Rake::Task[:default].clear
  task default: %i[prettier_check rubocop spec]
end
